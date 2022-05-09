# frozen_string_literal: true

require 'roda'

require_relative './system/boot'

# The main class for Roda Application.
class App < Roda
  # The environments plugin adds a environment class accessor to get the environment for the application,
  # 3 predicate class methods to check for the current environment (development?, test? and production?),
  # and a class configure method that takes environment(s) and yields to the block if the given environment(s)
  # match the current environment.
  plugin :environments

  # The heartbeat handles heartbeat/status requests.
  # If a request for the heartbeat path comes in, a 200 response with a text/plain
  # Content-Type and a body of 'OK' will be returned.
  # The default heartbeat path is '/heartbeat'.
  plugin :heartbeat

  configure :development, :production do
    # A powerful logger for Roda with a few tricks up it's sleeve.
    plugin :enhanced_logger
  end

  # Validate UUID
 # symbol_matcher :uuid, Constants::UUID_REGEX
  # The error_handler plugin adds an error handler to the routing,
  # so that if routing the request raises an error,
  # a nice error message page can be returned to the user.
  plugin :error_handler do |e|
    if e.instance_of?(Exceptions::InvalidParamsError)
      error_object    = e.object
      response.status = 422
    elsif e.instance_of?(Exceptions::InvalidEmailOrPassword)
      error_object    = { error: I18n.t('invalid_email_or_password') }
      response.status = 401
    elsif e.instance_of?(ActiveSupport::MessageVerifier::InvalidSignature)
      error_object    = { error: I18n.t('invalid_authorization_token') }
      response.status = 401
#    elsif e.instance_of?(Sequel::NoMatchingRow)
#      error_object    = { error: I18n.t('not_found') }
#      response.status = 404
    else
      error_object    = { error: I18n.t('something_went_wrong') }
      response.status = 500
    end

    response.write(error_object.to_json)
  end

  # The default_headers plugin accepts a hash of headers, and overrides
  # the default_headers method in the response class to be a copy of the headers.
  # Note that when using this module, you should not attempt to mutate of the values set in the default headers hash.
  plugin :default_headers,
         'Content-Type' => 'application/json',
         'Strict-Transport-Security' => 'max-age=16070400;',
         'X-Frame-Options' => 'deny',
         'X-Content-Type-Options' => 'nosniff',
         'X-XSS-Protection' => '1; mode=block'

  # The all_verbs plugin adds methods for http verbs other than get and post. The following verbs are added,
  # assuming rack handles them: delete, head, options, link, patch, put, trace, unlink.
  # These methods operate just like Roda's default get and post methods, so using them without any arguments
  # just checks for the request method, while using them with any arguments also checks that the arguments match the full path.
  plugin :all_verbs
  # This is mostly designed for use with JSON API sites.
  plugin :json_parser

  # It validates authorization token that was passed in Authorization header.
  #
  # @see AuthorizationTokenValidator
  def current_user
    return @current_user if @current_user

    purpose = request.url.include?('refresh_token') ? :refresh_token : :access_token

    @current_user = AuthorizationTokenValidator.new(
      authorization_token: env['HTTP_AUTHORIZATION'],
      purpose: purpose
    ).call
  end

  route do |r|
    r.on('api') do
      r.on('v1') do
        r.post('sign_up') do
          sign_up_params = SignUpParams.new.permit!(r.params)
          user           = Users::Creator.new(attributes: sign_up_params).call
          tokens         = AuthorizationTokensGenerator.new(user: user).call

          UserSerializer.new(user: user, tokens: tokens).render
        end

        r.post('login') do
          login_params = LoginParams.new.permit!(r.params)
          user         = Users::Authenticator.new(email: login_params[:email], password: login_params[:password]).call
          tokens       = AuthorizationTokensGenerator.new(user: user).call

          UserSerializer.new(user: user, tokens: tokens).render
        end

        r.delete('logout') do
          Users::UpdateAuthenticationToken.new(user: current_user).call

          response.write(nil)
        end

        r.post('refresh_token') do
          Users::UpdateAuthenticationToken.new(user: current_user).call

          tokens = AuthorizationTokensGenerator.new(user: current_user).call

          TokensSerializer.new(tokens: tokens).render
        end

        r.delete('delete_account') do
          DeleteAccountWorker.perform_async(current_user.id)

          response.write(nil)
        end

        r.on('todos') do
          # We are calling the current_user method to get the current user
          # from the authorization token that was passed in the Authorization header.
          current_user

          r.on(:uuid) do |id|
            todo = current_user.todos_dataset.with_pk!(id)

            r.get do
              TodoSerializer.new(todo: todo).render
            end

            r.put do
              todo_params = TodoParams.new.permit!(r.params)

              Todos::Updater.new(todo: todo, attributes: todo_params).call

              TodoSerializer.new(todo: todo).render
            end

            r.delete do
              todo.delete

              response.write(nil)
            end
          end

          r.get do
            todos_params = TodosParams.new.permit!(r.params)
            todos        = TodosQuery.new(dataset: current_user.todos_dataset, params: todos_params).call

            TodosSerializer.new(todos: todos).render
          end

          r.post do
            todo_params = TodoParams.new.permit!(r.params)
            todo        = Todos::Creator.new(user: current_user, attributes: todo_params).call

            TodoSerializer.new(todo: todo).render
          end
        end
      end
    end
  end
end
