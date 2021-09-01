module Bulk 
  class BulkUpload
    def initialize(file)
       @file = file
    end

    def process
      uploaded_file = @file
      File.open(Rails.root.join('public', uploaded_file.original_filename), 'wb') do |file|
        file.write(uploaded_file.read)
      end

      table = CSV.parse(File.read(Rails.root.join('public', uploaded_file.original_filename)), headers: true)
      x = 0
      batch_size = 1000
      
      while x < (table.size) 
        users = []
        all_users = []
        
        (batch_size).times do |i|
          country = table.by_row[x][" country"]
          cpc = table.by_row[x][" inbound_cpc"]  
          location = table.by_row[x][" location"]
          employment_type = table.by_row[x][" employment_type"]
          company_id = table.by_row[x][" company_id"]
          currency_code = table.by_row[x][" currency_code"]
          language_code = table.by_row[x][" language_code"]
          description = table.by_row[x][" description"]
          source = table.by_row[x][" source"]
          external_id = table.by_row[x][" external_id"]
          country_code = table.by_row[x][" country_code"]
          job_listing_id = table.by_row[x][" job_listing_id"]
          job_post_link = table.by_row[x][" job_post_link"]
          title = table.by_row[x][" title"]


         
            user = {"country" => ActiveRecord::Base.connection.quote(country), 
              "inbound_cpc" => ActiveRecord::Base.connection.quote(cpc),
              "location" => ActiveRecord::Base.connection.quote(location) ,
              "employment_type" => ActiveRecord::Base.connection.quote(employment_type) ,
              "company_id" => ActiveRecord::Base.connection.quote(company_id) ,
              "currency_code" => ActiveRecord::Base.connection.quote(currency_code) ,
              "language_code" => ActiveRecord::Base.connection.quote(language_code) ,
              "description" => ActiveRecord::Base.connection.quote(description) ,
              "source" => ActiveRecord::Base.connection.quote(source) ,
              "external_id" => ActiveRecord::Base.connection.quote(external_id) ,
              "country_code" => ActiveRecord::Base.connection.quote(country_code) ,
              "job_listing_id" => ActiveRecord::Base.connection.quote(job_listing_id),
              "job_post_link" => ActiveRecord::Base.connection.quote(job_post_link),
              "title" => ActiveRecord::Base.connection.quote(title),
              
                  }
            users.push(user)
          x = x + 1;
          if(x >= table.size) 
            break
          end
        end
        if(x <= table.size)
          for user in users
            all_users.push(<<-SQL.chomp)
            (
              #{user.values.join(',')}
            )
            SQL
          end

          if(all_users.size != 0)
            sql = <<-SQL.chomp
            INSERT INTO jobs (
              country, inbound_cpc, location, employment_type, company_id, currency_code, language_code, description, source, external_id,  country_code, job_listing_id, job_post_link, title
              ) VALUES #{all_users.join(',')}
              SQL
            ActiveRecord::Base.connection.execute(sql)
          end
        end
      end
    end
  end
end
