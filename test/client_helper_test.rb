require_relative 'helper'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash'

describe Recaptcha::ClientHelper do
  include Recaptcha::ClientHelper

  it "uses ssl" do
    recaptcha_tags.must_include "\"#{Recaptcha.configuration.api_server_url}\""
  end

  describe "noscript" do
    it "does not adds noscript tags when noscript is given" do
      recaptcha_tags(noscript: false).wont_include "noscript"
    end

    it "does not add noscript tags" do
      recaptcha_tags.must_include "noscript"
    end
  end

  describe "stoken" do
    let(:regex) { /" data-stoken="[1]" / }

    it "generates a secure token" do
      refute_nil Recaptcha::Token.secure_token
    end

    it "adds a security token by default" do
      html = recaptcha_tags
      html.sub!(/data-stoken="[^"]+"/, 'data-stoken="TOKEN"')
      html.must_include "<div class=\"g-recaptcha\" data-sitekey=\"0000000000000000000000000000000000000000\" data-stoken=\"TOKEN\"></div>"
    end

    it "does not add a security token when specified" do
      html = recaptcha_tags(stoken: false)
      html.must_include "<div class=\"g-recaptcha\" data-sitekey=\"0000000000000000000000000000000000000000\"></div>"
    end

    it "raises if secure_token is called without a private_key" do
      Recaptcha.configuration.private_key = nil
      assert_raises Recaptcha::RecaptchaError do
        Recaptcha::Token.secure_token
      end
    end
  end

  it "can include size" do
    html = recaptcha_tags(size: 10)
    html.must_include "<div class=\"g-recaptcha\" data-size=\"10\" data-sitekey=\"0000000000000000000000000000000000000000\""
  end

  it "raises withut public key" do
    Recaptcha.configuration.public_key = nil
    assert_raises Recaptcha::RecaptchaError do
      recaptcha_tags
    end
  end
end
