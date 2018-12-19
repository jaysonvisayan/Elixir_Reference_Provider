defmodule ProviderScheduler.Schedule do
  use Quantum.Scheduler,
    otp_app: :provider_scheduler
end
