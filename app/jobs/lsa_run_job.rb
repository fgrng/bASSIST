class LsaRunJob < ApplicationJob
  queue_as :default

  def perform(lsa_run_id)
    LsaRun.find(lsa_run_id).run
  end
end
