class RemoveDomainFromComponents < ActiveRecord::Migration[8.1]
  def change
    remove_reference :components, :domain
  end
end
