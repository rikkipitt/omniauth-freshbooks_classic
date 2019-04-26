require "spec_helper"
require "omniauth/freshbooks_classic"

describe OmniAuth::Strategies::FreshBooksClassic do
  subject do
    OmniAuth::Strategies::FreshBooksClassic.new(nil, @options || {})
  end

  describe "#client" do
    it "has correct access token path" do
      subject.options.client_options["access_token_path"].should eq("/oauth/oauth_access.php")
    end

    it "has correct authorize path" do
      subject.options.client_options["authorize_path"].should eq("/oauth/oauth_authorize.php")
    end

    it "has correct request token path" do
      subject.options.client_options["request_token_path"].should eq("/oauth/oauth_request.php")
    end

    it "has correct signature method" do
      subject.options.client_options["signature_method"].should eq("PLAINTEXT")
    end
  end

  describe "#info" do
    before :each do
      @raw_info = {
        "staff_id" => "1",
        "username" => "jsmith",
        "first_name" => "John",
        "last_name" => "Smith",
        "email" => "jsmith@example.org",
        "business_phone" => "(123) 456-7890",
        "mobile_phone" => "",
        "rate" => "0",
        "last_login" => "2008-11-20 13:26:00",
        "number_of_logins" => "13",
        "signup_date" => "2008-10-22 13:57:00",
        "street1" => "123 ABC Street",
        "street2" => "",
        "city" => "Toronto",
        "state" => "Ontario",
        "country" => "Canada",
        "code" => "M1M 1A1"
      }

      subject.stub(:raw_info) { @raw_info }
    end

    context "when data is present in raw info" do
      it "returns the combined name" do
        subject.info[:name].should eq("John Smith")
      end

      it "returns the first name" do
        subject.info[:first_name].should eq("John")
      end

      it "returns the last name" do
        subject.info[:last_name].should eq("Smith")
      end

      it "returns the email" do
        subject.info[:email].should eq("jsmith@example.org")
      end

      it "returns the nickname" do
        subject.info[:nickname].should eq("jsmith")
      end

      it "returns the user location" do
        subject.info[:location].should eq("Toronto, Ontario, Canada")
      end

      it "returns the phone" do
        subject.info[:phone].should eq("(123) 456-7890")
      end
    end
  end
end
