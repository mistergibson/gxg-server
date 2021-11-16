#!/usr/bin/env jruby
require 'rubygems'
# Load base deps
$GXGROOT = File.expand_path("./",File.dirname(__FILE__))
$DBROOT = "#{$GXGROOT}/System/Databases"
require 'gxg-framework'
# ### Define Directory Layout for Server
module GxG
  # Define Server directories, ensure directories are present
  gxg_root = $GXGROOT
  unless Dir.exist?(gxg_root)
      Dir.mkdir(gxg_root, 0775)
  end
  public_dir = File.expand_path("./Public",gxg_root)
  unless Dir.exist?(public_dir)
      Dir.mkdir(public_dir, 0775)
  end
  pub_theme_dir = "#{public_dir}/www/themes"
  unless Dir.exist?(pub_theme_dir)
      Dir.mkdir(pub_theme_dir, 0775)
  end
  pub_js_dir = "#{public_dir}/www/javascript"
  unless Dir.exist?(pub_js_dir)
      Dir.mkdir(pub_js_dir, 0775)
  end
  pub_image_dir = "#{public_dir}/www/images"
  unless Dir.exist?(pub_image_dir)
      Dir.mkdir(pub_image_dir, 0775)
  end
  pub_audio_dir = "#{public_dir}/www/audio"
  unless Dir.exist?(pub_audio_dir)
      Dir.mkdir(pub_audio_dir, 0775)
  end
  pub_video_dir = "#{public_dir}/www/video"
  unless Dir.exist?(pub_video_dir)
      Dir.mkdir(pub_video_dir, 0775)
  end
  #
  services_dir = File.expand_path("./Services",gxg_root)
  unless Dir.exist?(services_dir)
      Dir.mkdir(services_dir, 0775)
  end
  #
  app_dir = File.expand_path("./Applications",gxg_root)
  unless Dir.exist?(app_dir)
      Dir.mkdir(app_dir, 0775)
  end
  # ### Review : allow a configurable /Users mount point for VFS (mass storage??)
  # users_dir = File.expand_path("./Users",gxg_root)
  # unless Dir.exist?(users_dir)
  #     Dir.mkdir(users_dir, 0755)
  # end
  #
  system_dir = File.expand_path("./System",gxg_root)
  unless Dir.exist?(system_dir)
      Dir.mkdir(system_dir, 0755)
  end
  sys_config_dir = "#{system_dir}/Configuration"
  unless Dir.exist?(sys_config_dir)
      Dir.mkdir(sys_config_dir, 0755)
  end
  sys_db_dir = "#{system_dir}/Databases"
  unless Dir.exist?(sys_db_dir)
      Dir.mkdir(sys_db_dir, 0755)
  end
  sys_ext_dir = "#{system_dir}/Extensions"
  unless Dir.exist?(sys_ext_dir)
      Dir.mkdir(sys_ext_dir, 0755)
  end
  sys_gem_dir = "#{system_dir}/Gems"
  unless Dir.exist?(sys_gem_dir)
      Dir.mkdir(sys_gem_dir, 0755)
  end
  sys_lib_dir = "#{system_dir}/Libraries"
  unless Dir.exist?(sys_lib_dir)
      Dir.mkdir(sys_lib_dir, 0755)
  end
  user_dir = "#{system_dir}/Users"
  unless Dir.exist?(user_dir)
      Dir.mkdir(user_dir, 0755)
  end
  user_share_dir = "#{system_dir}/Users/Shared"
  unless Dir.exist?(user_share_dir)
      Dir.mkdir(user_share_dir, 0755)
  end
  tmp_dir = "#{system_dir}/Temporary"
  log_dir = "#{system_dir}/Logs"
  SERVER_PATHS = {:root => gxg_root, :system => system_dir, :services => services_dir, :temporary => tmp_dir, :logs => log_dir, :applications => app_dir, :public => public_dir,  :configuration => sys_config_dir, :themes => pub_theme_dir, :javascript => pub_js_dir, :images => pub_image_dir, :audio => pub_audio_dir, :video => pub_video_dir, :databases => sys_db_dir, :extensions => sys_ext_dir, :gems => sys_gem_dir, :libraries => sys_lib_dir, :users => user_dir}
end
# Core Configuration
unless File.exists?("#{GxG::SERVER_PATHS[:configuration]}/core.json")
    handle = File.open("#{GxG::SERVER_PATHS[:configuration]}/core.json", "wb")
    handle.write(::JSON.pretty_generate({:enabled => ["www"], :disabled => [], :available => ["www"]}))
    handle.close
end
# WWW Configuration
unless File.exists?("#{GxG::SERVER_PATHS[:configuration]}/www.json")
    handle = File.open("#{GxG::SERVER_PATHS[:configuration]}/www.json", "wb")
    handle.write(::JSON.pretty_generate({:mode => "production", :listen => [{:address => "127.0.0.1", :port => 32767}], :relative_url => "", :cache_quota => 1073741824, :cache_max_item_size => 1073741824}))
    handle.close
end
# DB configuration
def configure_db()
    # Construct default configuration files:
    # Database Configuration:
    if File.exists?("#{GxG::SERVER_PATHS[:configuration]}/databases.json")
        handle = File.open("#{GxG::SERVER_PATHS[:configuration]}/databases.json", "rb")
        db_config = ::JSON::parse(handle.read(), {:symbolize_names => true})
        handle.close
    else
        # paths are REALITIVE to the system db dir
        db_config = {:databases => [{:url => "sqlite://default.gxg", :roles => ["users", "data", "formats", "vfs"]},{:url => "sqlite://Content.gxg", :roles => ["content"]},{:url => "sqlite://Software.gxg", :roles => ["software"]},{:url => "sqlite://Reference.gxg", :roles => ["reference"]}]}
        #
    end
    puts "Current database configuration:\n#{db_config[:databases].inspect}\n"
    puts "--------------------------\n"
    puts "0) save, 1) create new db config\n"
    if gets("\n").to_s.split("\n")[0].to_s.to_i == 1
        new_config = []
        editing = true
        while editing == true do
        puts "Current NEW configuration:\n#{new_config.inspect}\n"
        puts "--------------------------\n"
        puts "\nEnter a database URL (mysql://<user_id>:<password>@<host>/<database_name>) :\n"
        the_url = gets("\n").to_s.split("\n")[0].to_s
        puts "\nEnter the roles that this database serves (users, data, formats, vfs, reference) comma separated, no-spaces :\n"
        the_roles = gets("\n").to_s.split("\n")[0].to_s.gsub(" ","").split(",")
        new_config << {:url => the_url, :roles => the_roles}
        puts "0) save as is, 1) add new db entry\n"
        if gets("\n").to_s.split("\n")[0].to_s.to_i == 0
            editing = false
            db_config[:databases] = new_config
        end
        end
    end
    #
    if File.exists?("#{GxG::SERVER_PATHS[:configuration]}/databases.json")
        File.delete("#{GxG::SERVER_PATHS[:configuration]}/databases.json")
    end
    handle = File.open("#{GxG::SERVER_PATHS[:configuration]}/databases.json","w+b", 0664)
    handle.write(::JSON.pretty_generate(db_config))
    handle.close
    # Return db_config
    db_config
    #
end
db_configuration = configure_db()
# VFS configuration
def configure_vfs()
    # VFS Mounting Configuration:
    reserved_roles = ["users", "data"]
    if File.exists?("#{GxG::SERVER_PATHS[:configuration]}/mounts.json")
      handle = File.open("#{GxG::SERVER_PATHS[:configuration]}/mounts.json", "rb")
      mount_config = ::JSON::parse(handle.read(), {:symbolize_names => true})
      handle.close
    else
      mount_config = {:mount_points => [{:db_role => "vfs", :path => "/Storage"}, {:db_role => "reference", :path => "/Reference"}, {:file_system => "./Users", :path => "/User"}, {:db_role => "content", :path => "/Public/www/content"}, {:db_role => "software", :path => "/Public/www/software"}]}
      handle = File.open("#{GxG::SERVER_PATHS[:configuration]}/mounts.json","w+b", 0664)
      handle.write(::JSON.pretty_generate(mount_config))
      handle.close
    end
    puts "Current VFS mount point configuration:\n#{mount_config[:mount_points].inspect}\n"
    puts "--------------------------\n"
    puts "0) save, 1) create new mount points\n"
    if gets("\n").to_s.split("\n")[0].to_s.to_i == 1
      new_config = []
      editing = true
      while editing == true do
        puts "Current NEW configuration:\n#{new_config.inspect}\n"
        puts "--------------------------\n"
        puts "\nEnter a: 0) DB Role mount point, 1) File System mount point\n"
        record = {}
        choice = gets("\n").to_s.split("\n")[0].to_s.to_i
        if choice == 0
          puts "\nEnter the DB Role to mount (one only):\n"
          the_role = gets("\n").to_s.split("\n")[0].to_s
          record[:db_role] = the_role
        else
          puts "\nEnter a full File System path to mount:\n"
          the_fs = gets("\n").to_s.split("\n")[0].to_s
          record[:file_system] = the_fs
        end
        puts "\nEnter a VFS path to serve as mount point\n"
        the_vfs = gets("\n").to_s.split("\n")[0].to_s
        record[:path] = the_vfs
        new_config << record
        puts "0) save as is, 1) add another mount point\n"
        if gets("\n").to_s.split("\n")[0].to_s.to_i == 0
          editing = false
          mount_config[:mount_points] = new_config
        end
      end
    end
    if File.exists?("#{GxG::SERVER_PATHS[:configuration]}/mounts.json")
      File.delete("#{GxG::SERVER_PATHS[:configuration]}/mounts.json")
    end
    handle = File.open("#{GxG::SERVER_PATHS[:configuration]}/mounts.json","w+b", 0664)
    handle.write(::JSON.pretty_generate(mount_config))
    handle.close
    # Return mount_config
    mount_config
    #
end
mount_configuration = configure_vfs()
# Define DB Pool
def db_pool_setup(db_config)
    db_pool = {}
    if db_config[:databases].is_a?(::Array)
      authority = nil
      db_config[:databases].each do |entry|
        puts "Mounting or creating a database ..."
        # Define absolue DB paths from url
        # $DBROOT
        if ::URI::parse(entry[:url]).scheme.downcase == "sqlite"
            if ::URI::parse(entry[:url]).hostname.to_s[0] == "/" || ::URI::parse(entry[:url]).path.to_s[0] == "/"
                # absolute path
                the_db_url = entry[:url]
            else
                # relative path
                the_db_url = "sqlite://#{$DBROOT}/#{::URI::parse(entry[:url]).hostname}"
            end
        else
            the_db_url = entry[:url]
        end
        #
        if authority
          the_db = ::GxG::Database::connect(the_db_url, {:authority => authority})
        else
          the_db = ::GxG::Database::connect(the_db_url)
        end
        if the_db
          entry[:roles].each do |the_role|
            unless db_pool[(the_role.to_sym)]
              db_pool[(the_role.to_sym)] = the_db
              GxG::DB[:roles][(the_role.to_sym)] = the_db
              if the_role == "users"
                authority = the_db
                GxG::DB[:authority] = the_db
              end
            end
          end
        end
      end
    else
      # malformed config
    end
    #
    # Return db_pool
    db_pool
    #
end
db_pool_configuration = db_pool_setup(db_configuration)
def admin_setup(db_pool, mount_config)
    credential = nil
    #
    if db_pool.size > 0
        begin
            unless db_pool[:users].user_id_available?("root")
                credential = db_pool[:users].user_credential("root","password")
            end
        rescue Exception => the_error
        end
        if credential
            puts "Found root using credential: #{credential.inspect}"
            puts "Enter new root UserID: (default 'root')\n"
            new_id = gets("\n").to_s.split("\n")[0].to_s
            if new_id.size > 0
                db_pool[:users].user_update(credential,new_id)
            end
            puts "Enter new root Password: (default 'password')\n"
            new_pw = gets("\n").to_s.split("\n")[0].to_s
            if new_pw.size > 0
                db_pool[:users].user_set_password(credential,"password",new_pw)
            end
            #
            admin_config = {:credential => credential}
            if File.exists?("#{GxG::SERVER_PATHS[:configuration]}/db_admin.json")
                File.delete("#{GxG::SERVER_PATHS[:configuration]}/db_admin.json")
            end
            handle = File.open("#{GxG::SERVER_PATHS[:configuration]}/db_admin.json","w+b", 0664)
            handle.write(::JSON.pretty_generate(admin_config))
            handle.close
            GxG::DB[:administrator] = credential
        else
            # has already been setup.
            if File.exists?("#{GxG::SERVER_PATHS[:configuration]}/db_admin.json")
                handle = File.open("#{GxG::SERVER_PATHS[:configuration]}/db_admin.json","rb")
                admin_config = ::JSON::parse(handle.read(), {:symbolize_names => true})
                handle.close
                credential = admin_config[:credential]
                GxG::DB[:administrator] = credential
                puts "Found credential: #{credential.inspect}"
            else
                raise Exception, "Cannot find required db_admin.json file to work with."
            end
        end
    end
    #
    if credential && db_pool.size > 0
      volume = nil
      mount_config[:mount_points].each do |entry|
        if entry[:db_role]
          the_db = db_pool[(entry[:db_role].to_sym)]
          if the_db
            volume = ::GxG::Storage::Volume.new({:database => the_db, :credential => credential})
          end
        end
        if entry[:file_system]
          volume = ::GxG::Storage::Volume.new({:directory => entry[:file_system]})
        end
        if volume
          GxG::VFS.mount(volume, entry[:path])
          volume = nil
        end
      end
    end
    # Retrurn admin_config
    admin_config
end
admin_configuration = admin_setup(db_pool_configuration, mount_configuration)
# Load formats
puts "Creating Formats ..."
require (File.expand_path("./seeds/formats.rb",File.dirname(__FILE__)))
# Seed Reference Data
# puts "Seeding reference data ... (This takes a VERY long time)"
# ### Currencies
# if ::GxG::DB[:roles][:reference].uuid_list(::GxG::DB[:administrator], {:ufs => "org.gxg.exchange.currency"}).size == 0
#     handle = File.open("#{$GXGROOT}/seeds/political_currencies.gxg_export","rb")
#     begin
#         raw_data = ::JSON::parse(handle.read().transcode(::Encoding::UTF_8, {:undef => :replace, :invalid => :replace, :replace => "."}),{:symbolize_names => true})
#     rescue Exception => the_error
#         log_error(:error => the_error, :parameters => {})
#         puts "Error reading political_currencies - skipping ..."
#         raw_data = nil
#     end
#     handle.close
#     if raw_data
#         puts "Currency Processing: Starting: #{DateTime.now.to_s}"
#         ::GxG::DB[:roles][:reference].sync_import(::GxG::DB[:administrator], raw_data)
#         puts "Currency Processing: Ending: #{DateTime.now.to_s}"
#     end
# else
#     puts "Currencies already loaded - skipping importation."
# end
#
# handle = File.open("#{$GXGROOT}/seeds/political_currencies.json","rb")
# # 1) json convert, 2) create new currency records, 3) db.sync export to new file "political_currencies.gxg_export", 4) rewrite this section to import that file.
# begin
#     raw_data = ::JSON::parse(handle.read(),{:symbolize_names => true})[:political_currencies]
# rescue Exception => the_error
#     puts "Error reading political_currencies - skipping ..."
#     raw_data = nil
# end
# handle.close
# export_uuid_list = []
# if raw_data.is_a?(::Array)
#     database = ::GxG::DB[:roles][:reference]
#     raw_data.each do |the_record|
#         new_record = database.new_structure_from_format(::GxG::DB[:administrator],{:ufs => "org.gxg.exchange.currency"})
#         new_record.wait_for_reservation
#         new_record[:iso] = the_record[:iso]
#         new_record[:iso_number] = the_record[:iso_num]
#         new_record[:symbol] = the_record[:symbol]
#         new_record[:name] = the_record[:name]
#         new_record.set_title(the_record[:name])
#         if the_record[:name].downcase.include?("dollar") || the_record[:name].downcase.include?("pound") || the_record[:name].downcase.include?("euro")
#             new_record[:unit_multiplier] = 100
#         end
#         new_record.save
#         new_record.set_permissions(:"00000000-0000-4000-0000-000000000000", {:read => true})
#         export_uuid_list << new_record.uuid
#         new_record.deactivate
#         puts "Processed: #{the_record.inspect}"
#     end
# end
# if export_uuid_list.size > 0
#     handle = File.open("#{$GXGROOT}/seeds/political_currencies.gxg_export","w+b")
#     handle.write(::JSON::pretty_generate(::GxG::DB[:roles][:reference].sync_export(::GxG::DB[:administrator], export_uuid_list)))
#     handle.close
# end
# ### Regions : Nations & Territories
# search_database
# if ::GxG::DB[:roles][:reference].uuid_list(::GxG::DB[:administrator], {:ufs => "org.gxg.region"}).size == 0
#     handle = File.open("#{$GXGROOT}/seeds/regions.gxg_export","rb")
#     begin
#         raw_data = ::JSON::parse(handle.read().transcode(::Encoding::UTF_8),{:symbolize_names => true})
#     rescue Exception => the_error
#         puts "Error reading regions - skipping ..."
#         raw_data = nil
#     end
#     handle.close
#     if raw_data
#         puts "Regions Processing: Starting: #{DateTime.now.to_s}"
#         ::GxG::DB[:roles][:reference].sync_import(::GxG::DB[:administrator], raw_data)
#         puts "Regions Processing: Ending: #{DateTime.now.to_s}"
#     end
# else
#     puts "Regions (Nations & Territories) already loaded - skipping importation."
# end
# handle = File.open("#{$GXGROOT}/seeds/regions.json","rb")
# # 1) json convert, 2) create new currency records, 3) db.sync export to new file "political_currencies.gxg_export", 4) rewrite this section to import that file.
# begin
#     raw_data = ::JSON::parse(handle.read().transcode(::Encoding::UTF_8),{:symbolize_names => true})
# rescue Exception => the_error
#     puts "Error reading regions - skipping ..."
#     raw_data = nil
# end
# handle.close
# export_uuid_list = []
# old_new_map = {}
# if raw_data.is_a?(::Array)
#     database = ::GxG::DB[:roles][:reference]
#     raw_data.each do |the_record|
#         new_record = database.new_structure_from_format(::GxG::DB[:administrator],{:ufs => "org.gxg.region"})
#         new_record.wait_for_reservation
#         #
#         old_new_map[(the_record[:uuid].to_s.to_sym)] = new_record.uuid.to_s
#         new_record[:scale] = the_record[:scale]
#         new_record[:designation] = the_record[:designation]
#         new_record[:iso_code] = the_record[:iso_code].to_s
#         new_record[:iso_number] = the_record[:iso_num].to_s
#         new_record[:iso_two_letter] = the_record[:iso2].to_s
#         new_record[:iso_three_letter] = the_record[:iso3].to_s
#         new_record[:iso_name] = the_record[:iso_name]
#         new_record[:abbreviation] = the_record[:abbreviation]
#         new_record[:name] = the_record[:name]
#         new_record.set_title(the_record[:name])
#         #
#         new_record.save
#         new_record.set_permissions(:"00000000-0000-4000-0000-000000000000", {:read => true})
#         export_uuid_list << new_record.uuid
#         #
#         the_record[:territories].each do |the_territory_record|
#             puts "Processing: ... #{the_territory_record[:name]} ..."
#             #
#             new_territory = database.new_structure_from_format(::GxG::DB[:administrator],{:ufs => "org.gxg.region"})
#             new_territory.wait_for_reservation
#             new_territory[:within_region_uuid] = old_new_map[(the_record[:uuid].to_s.to_sym)]
#             new_territory[:scale] = the_territory_record[:scale]
#             new_territory[:designation] = the_territory_record[:designation]
#             new_territory[:iso_code] = the_territory_record[:iso_code].to_s
#             new_territory[:iso_number] = the_territory_record[:iso_num].to_s
#             new_territory[:iso_two_letter] = the_territory_record[:iso2].to_s
#             new_territory[:iso_three_letter] = the_territory_record[:iso3].to_s
#             new_territory[:iso_name] = the_territory_record[:iso_name]
#             new_territory[:abbreviation] = the_territory_record[:abbreviation]
#             new_territory[:name] = the_territory_record[:name]
#             new_territory.set_title(the_territory_record[:name])
#             export_uuid_list << new_territory.uuid
#             #
#             new_territory.save
#             new_territory.set_permissions(:"00000000-0000-4000-0000-000000000000", {:read => true})
#             new_territory.deactivate
#         end
#         #
#         new_record.deactivate
#         puts "Processed: #{the_record.inspect}"
#     end
# end
# if export_uuid_list.size > 0
#     handle = File.open("#{$GXGROOT}/seeds/regions.gxg_export","w+b")
#     handle.write(::JSON::pretty_generate(::GxG::DB[:roles][:reference].sync_export(::GxG::DB[:administrator], export_uuid_list)))
#     handle.close
# end
# ### Currencies
# if ::GxG::DB[:roles][:reference].uuid_list(::GxG::DB[:administrator], {:ufs => "org.gxg.region"}).size == 0
#     handle = File.open("#{$GXGROOT}/seeds/regions.gxg_export","rb")
#     begin
#         raw_data = ::JSON::parse(handle.read().transcode(::Encoding::UTF_8, {:undef => :replace, :invalid => :replace, :replace => "."}),{:symbolize_names => true})
#     rescue Exception => the_error
#         log_error(:error => the_error, :parameters => {})
#         puts "Error reading regions - skipping ..."
#         raw_data = nil
#     end
#     handle.close
#     if raw_data
#         puts "Region Processing: Starting: #{DateTime.now.to_s}"
#         ::GxG::DB[:roles][:reference].sync_import(::GxG::DB[:administrator], raw_data)
#         puts "Region Processing: Ending: #{DateTime.now.to_s}"
#     end
# else
#     puts "Regions already loaded - skipping importation."
# end
#
# ### Content / Software configuration
puts "Populating Website (defaults) ..."
require (File.expand_path("./seeds/content_setup.rb",File.dirname(__FILE__)))
::GxGwww::Setup::populate_new_site()
