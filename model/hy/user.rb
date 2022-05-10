module Hy 
  class  User < Arcade::Vertex
    attribute :name, Types::Nominal::String
    attribute :surname, Types::Nominal::String.default( "".freeze )
    attribute :email, Types::Nominal::String.constrained( format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i )
    attribute :signal?, Types::Nominal::String
    attribute :telegram?, Types::Nominal::String
    attribute :age?, Types::Nominal::Integer
    attribute :wallet?, Types::Nominal::String
    attribute :authentication_token?, Types::Nominal::String
    attribute :created, Types::Nominal::Date.default( Date.today.freeze)
    attribute :active, Types::Nominal::Bool.default( true )
    attribute :conterfeil?, Types::Nominal::Any

#  def parent
#    query( where: {child: rid})
#  end


   def self.db_init
      File.read(__FILE__).gsub(/.*__END__/m, '')
    end
  end
end
## The code below is executed on the database after the database-type is created
## Use the output of `ModelClass.database_name` as DB type  name
## 
__END__
CREATE PROPERTY hy_user.name STRING
CREATE PROPERTY hy_user.surname STRING
CREATE PROPERTY hy_user.email STRING
CREATE PROPERTY hy_user.wallet STRING
CREATE PROPERTY hy_user.authentication_token STRING
CREATE INDEX `User[name]` ON hy_user ( name ) NOTUNIQUE
CREATE INDEX `User[allnames` ON hy_user ( name, surname, email ) UNIQUE
CREATE INDEX `User[wallet]` ON hy_user ( wallet ) UNIQUE
CREATE INDEX `User[token]` ON hy_user ( authentication_token ) UNIQUE
