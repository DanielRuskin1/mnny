namespace :account_imports do
  desc "Process account imports and delete orphaned files."
  task process: :environment do
    AccountImport.process_pending_and_delete_orphaned_files
  end
end
