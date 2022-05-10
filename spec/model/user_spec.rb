require 'spec_helper'
require 'arcade_helper'
###
# The model directory  `spec/model` contains some sample files
# #
# These are used in the following tests
#
# In projects, define the model files and include them  via zeitwerk
#
#    loader = Zeitwerk::Loader.new
#    loader.push_dir("#{__dir__}/model")
#    loader.setup
#
#
RSpec.describe Hy::User do
  before(:all) do
    clear_arcade
    Arcade::Database.new :test
    Hy::User.create_type
  end


  context "CRUD" do     ##  unfinised
    it  "create a record" do
      record =  Hy::User.create name: 'Hugo', age: 40, email: "hugo@mail.local"
      expect( record ).to be_a Hy::User
      expect( record.rid ).to  match /\A[#]{,1}[0-9]{1,}:[0-9]{1,}\z/
      expect( record.name ).to eq "Hugo"
      expect( record.age ).to eq 40
      expect( Hy::User.count ).to eq 1
    end

    it "with constrains" do
      record =  Hy::User.create name: 'Hugo', age: '40',  email: "hugo@mail.local"

      expect( Hy::User.count ).to eq 1
    end


    it "read that record" do
      the_record =  Hy::User.last
      expect( the_record ).to be_a Hy::User
      expect( the_record.name ).to be_a String
      expect( the_record.age ).to be_a Integer
    end
    it "update it" do
      the_record =  Hy::User.last.update( surname: "Gertrude" )
      expect( the_record ).to be_a Hy::User
      expect( the_record.name ).to eq "Hugo"
      expect( the_record.surname ).to eq "Gertrude"
    end

    it "and finally destroy the record" do
      the_record =  Hy::User.last
      expect( the_record.delete ).to be_truthy
      expect( Hy::User.count ).to be_zero
    end
  end
end
