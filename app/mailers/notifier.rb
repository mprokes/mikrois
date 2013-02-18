class Notifier < ActionMailer::Base
  default from: "no-reply@kropes.cz", return_path: "michal@kropes.cz"

  def welcome(recipient)
    @user = recipient
    mail(:to => recipient.email,
         :bcc => ["michal@kropes.cz", "Michal Prokes <michal@kropes.cz>"])
  end
end
