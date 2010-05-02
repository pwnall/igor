class RemoveProfileHasFields < ActiveRecord::Migration
  def self.up
    Profile.all.each do |profile|
      profile.phone_number = nil unless profile.has_phone?
      profile.aim_name = nil unless profile.has_aim?
      profile.jabber_name = nil unless profile.has_jabber?
      profile.save!
    end
    remove_column :profiles, :has_phone
    remove_column :profiles, :has_aim
    remove_column :profiles, :has_jabber
  end

  def self.down
    add_column :profiles, :has_phone, :boolean, :null => false,
                                                :default => false
    add_column :profiles, :has_aim, :boolean, :null => false, :default => false
    add_column :profiles, :has_jabber, :boolean, :null => false,
                                                 :default => false
    Profile.all.each do |profile|
      profile.has_phone = !profile.phone_number.nil?
      profile.has_aim = !profile.aim_name.nil?
      profile.has_jabber = profile.jabber_name.nil?
      profile.save!
    end    
    change_column :profiles, :has_phone, :boolean, :null => false,
                                                   :default => true
  end
end
