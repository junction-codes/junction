# frozen_string_literal: true

require "axe-rspec"

# axe drives Selenium directly in two places that Cuprite has no analogue for:
# `browser.manage.timeouts` while walking frames, and `execute_async_script`.
#
# Legacy mode skips the first by auditing the page in a single call rather than
# frame by frame. The cost is that iframe content is not audited. We use Turbo
# frames, but not iframes, so nothing here is missed.
Axe::Configuration.instance.legacy_mode = true

# The polling fallback below waits this long for `axe.run` to settle. The
# default is Capybara's 2s, which the larger pages overrun.
Axe::Configuration.instance.max_wait_time = 30

# The second is only a plumbing problem. `ExecuteAsyncScriptAdapter` already
# carries a driver-agnostic implementation that polls a global through
# `execute_script`/`evaluate_script`, both of which Cuprite supports, but
# `Axe::API::Run#audit` calls `execute_async_script_fixed`, which unwraps the
# adapter and goes straight to the native browser method. Fall back to the
# adapter's own implementation when the browser has no native one.
module WebDriverScriptAdapter
  class ExecuteAsyncScriptAdapter
    def execute_async_script_fixed(script, *args)
      native = __getobj__
      native = native.driver if native.respond_to?(:driver)
      if native.respond_to?(:browser) && !native.browser.is_a?(::Symbol)
        native = native.browser
      end

      return native.execute_async_script(script, *args) if
        native.respond_to?(:execute_async_script)

      execute_async_script(script, *args)
    end
  end
end
