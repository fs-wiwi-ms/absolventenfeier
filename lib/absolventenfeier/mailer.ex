defmodule Absolventenfeier.Mailer do
  use Bamboo.Mailer,
    otp_app: :absolventenfeier,
    adapter: Bamboo.SMTPAdapter
end
