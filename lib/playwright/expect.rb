module Playwright
  # ref: https://github.com/microsoft/playwright-python/blob/59369fe126f49c10597d5c9099840bdc8ccdcf15/playwright/sync_api/__init__.py#L90
  class Expect
    def initialize
      @timeout_settings = TimeoutSettings.new
    end

    def call(actual, message = nil)
      case actual
      in Locator
        LocatorAssertions.new(
          LocatorAssertionsImpl.new(
            actual,
            @timeout_settings.timeout,
            false,
            message,
          )
        )
      else
        raise NotImplementedError.new('NOT IMPLEMENTED')
      end
    end

    def self.call(actual, message = nil)
      self.new.call(actual, message)
    end

    class << self
      alias_method :[], :call
    end
  end
end