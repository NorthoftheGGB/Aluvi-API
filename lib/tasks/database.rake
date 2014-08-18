namespace :db do
	namespace :structure do
		task :add_postgis_extension do
			puts "HACK! Adding `CREATE EXTENSION postgis;` to structure.sql (see db_strucute_dump.rake)"

			structure_dump = Rails.root + "db/development_structure.sql"
			new_structure_dump = Rails.root + "db/new_structure.sql"

			new_file = File.open(new_structure_dump, 'w')
			existing = File.open(structure_dump)

			new_file << "CREATE EXTENSION postgis; \n"
			existing.each do |line|
				new_file << line
			end

			existing.close
			new_file.close
			FileUtils.mv(new_structure_dump, structure_dump)
		end

	end
end

# Rake::Task["db:structure:dump"].enhance do
#		Rake::Task["db:structure:add_postgis_extension"].invoke
# end

# Rake::Task["db:test:prepare"].clear


Rake::Task["db:structure:dump"].clear if Rails.env.production?
