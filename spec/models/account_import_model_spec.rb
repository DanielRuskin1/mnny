require "rails_helper"
require "models/model_spec_helper"

# TODO: The stubs here are dirty
RSpec.describe AccountImport, type: :model do
  let(:account) { create(:account) }
  let(:account_import) { create(:account_import, account: account) }

  describe ".process_pending_and_delete_orphaned_files" do
    it "processes all pending AccountImports" do
      account_import

      expect_any_instance_of(AccountImport).to receive(:process!) do |instance|
        expect(instance.id).to eq(account_import.id)
      end

      allow(FogConnections)
        .to receive_message_chain(:s3_connection, :directories, :new, :files)
        .and_return([])

      AccountImport.process_pending_and_delete_orphaned_files
    end
  end

  describe "#process!" do
    it "should process the AccountImport" do
      file = account_import.csv_file
      allow(file).to receive(:read).and_return(File.read("spec/fixtures/account_import.csv"))
      allow(account_import).to receive(:csv_file).and_return(file)

      # Stub out some problematic calls (these trigger exceptions, e.g. due to S3 queries)
      expect(UserMailer).to receive(:account_import_success).and_return(double("Class", deliver: true))
      expect(account_import).to receive(:destroy!)

      original_balance_record_count = BalanceRecord.where(
        balance_record_set_id: account.balance_record_sets.pluck(:id)
      ).count

      expect do
        account_import.process!
      end.to change(account.balance_record_sets, :count).by(3)

      new_balance_record_count = BalanceRecord.where(
        balance_record_set_id: account.balance_record_sets.pluck(:id)
      ).count

      expect(new_balance_record_count).to eq(original_balance_record_count + 3)
    end
  end
end
