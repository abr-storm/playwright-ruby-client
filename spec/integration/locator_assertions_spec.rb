require "spec_helper"
require "playwright/test"

# ref: https://github.com/microsoft/playwright-python/blob/main/tests/sync/test_assertions.py
RSpec.describe Playwright::LocatorAssertions, sinatra: true do
  include Playwright::Test::RSpec

  it "should work with #to_contain_text" do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div id=foobar>kek</div>")
      expect(page.locator("div#foobar")).to contain_text("kek")
      expect(page.locator("div#foobar")).to not_contain_text("bar", timeout: 100)

      expect {
        expect(page.locator("div#foobar")).to contain_text("bar", timeout: 100)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)

      page.set_content("<div>Text \n1</div><div>Text2</div><div>Text3</div>")
      expect(page.locator("div")).to contain_text(["ext    1", /ext3/])
    end
  end

  it "should work with #to_have_attribute" do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div id=foobar>kek</div>")
      expect(page.locator("div#foobar")).to have_attribute("id", "foobar")
      expect(page.locator("div#foobar")).to have_attribute("id", /foobar/)
      expect(page.locator("div#foobar")).to not_have_attribute("id", "kek", timeout: 100)
      
      expect {
        expect(page.locator("div#foobar")).to have_attribute("id", "koko", timeout: 100)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  it "should work with #to_have_class" do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div class=foobar>kek</div>")
      expect(page.locator("div.foobar")).to have_class("foobar")
      expect(page.locator("div.foobar")).to have_class(["foobar"])
      expect(page.locator("div.foobar")).to have_class(/foobar/)
      expect(page.locator("div.foobar")).to not_have_class("kekstar", timeout: 100)

      expect {
        expect(page.locator("div.foobar")).to have_class("oh-no", timeout: 100)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  it "should work with #to_have_count" do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div class=foobar>kek</div><div class=foobar>kek</div>")
      expect(page.locator("div.foobar")).to have_count(2)
      expect(page.locator("div.foobar")).to not_have_count(42, timeout: 100)

      expect {
        expect(page.locator("div.foobar")).to have_count(42, timeout: 100)
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  it "should work with #to_have_css" do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div class=foobar style='color: rgb(234, 74, 90);'>kek</div>")
      expect(page.locator("div.foobar")).to have_css("color", "rgb(234, 74, 90)")
      expect(page.locator("div.foobar")).to not_have_css(
        "color", "rgb(42, 42, 42)", timeout: 100)
     
      expect {
        expect(page.locator("div.foobar")).to have_css(
          "color", "rgb(42, 42, 42)", timeout: 100
        )
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  it "should work with #to_have_id" do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div class=foobar id=kek>kek</div>")
      expect(page.locator("div.foobar")).to have_id("kek")
      expect(page.locator("div.foobar")).to not_have_id("top", timeout: 100)
      
      expect {
        expect(page.locator("div.foobar")).to have_id("top", timeout: 100)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  it "should work with #to_have_js_property" do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div></div>")
      page.eval_on_selector(
        "div", "e => e.foo = { a: 1, b: 'string', c: new Date(1627503992000) }"
      )
      expect(page.locator("div")).to have_js_property(
        "foo",
        { "a" => 1, "b" => "string", "c" => Time.at(1627503992000 / 1000) }
      )
    end
  end

  it "should work with #to_have_js_property pass string" do
    with_page do |page|
      page.set_content("<div></div>")
      page.eval_on_selector("div", "e => e.foo = 'string'")
      locator = page.locator("div")
      expect(locator).to have_js_property("foo", "string")
    end
  end

  it "should work with #to_have_js_property fail string" do
    with_page do |page|
      page.set_content("<div></div>")
      page.eval_on_selector("div", "e => e.foo = 'string'")
      locator = page.locator("div")
      expect {
        expect(locator).to have_js_property("foo", "error", timeout: 500)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  it "should work with #to_have_js_property pass number" do
    with_page do |page|
      page.set_content("<div></div>")
      page.eval_on_selector("div", "e => e.foo = 2021")
      locator = page.locator("div")
      expect(locator).to have_js_property("foo", 2021)
    end
  end

  it "should work with #to_have_js_property fail number" do
    with_page do |page|
      page.set_content("<div></div>")
      page.eval_on_selector("div", "e => e.foo = 2021")
      locator = page.locator("div")

      expect {
        expect(locator).to have_js_property("foo", 1, timeout: 500)
      }
    end
  end 

  it "should work with #to_have_js_property pass boolean" do
    with_page do |page|
      page.set_content("<div></div>")
      page.eval_on_selector("div", "e => e.foo = true")
      locator = page.locator("div")
      expect(locator).to have_js_property("foo", true)
    end
  end

  it "should work with #to_have_js_property fail boolean" do
    with_page do |page|
      page.set_content("<div></div>")
      page.eval_on_selector("div", "e => e.foo = false")
      locator = page.locator("div")

      expect {
        expect(locator).to have_js_property("foo", true, timeout: 500)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  it "should work with #to_have_js_property pass boolean 2" do
    with_page do |page|
      page.set_content("<div></div>")
      page.eval_on_selector("div", "e => e.foo = false")
      locator = page.locator("div")
      expect(locator).to have_js_property("foo", false)
    end
  end

  it "should work with #to_have_js_property fail boolean 2" do
    with_page do |page|
      page.set_content("<div></div>")
      page.eval_on_selector("div", "e => e.foo = true")
      locator = page.locator("div")

      expect {
        expect(locator).to have_js_property("foo", false, timeout: 500)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  it "should work with #to_have_js_property pass null" do
    with_page do |page|
      page.set_content("<div></div>")
      page.eval_on_selector("div", "e => e.foo = null")
      locator = page.locator("div")
      expect(locator).to have_js_property("foo", nil)
    end
  end
end