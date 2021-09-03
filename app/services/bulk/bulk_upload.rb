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

      doc = File.open(Rails.root.join('public', "jobsangebote_partner_medium.xml")) { |f| Nokogiri::XML(f) }
            x = 0
            sql = ""
            batch_size = 1000
            all_jobs = []
            ids = []
            doc.css('job').each do |node|
                x = x + 1;
                children = node.children
                ids << children.css('id').inner_text
            end

      table = CSV.parse(File.read(Rails.root.join('public', uploaded_file.original_filename)), headers: true) 
      x = 0
      batch_size = 1000
      all_job_listing_ids = []
      all_ids = []
      
      while x < (table.size) 
        users = []
        all_users = []
        
        (batch_size).times do |i|
          job_listing_id = table.by_row[x]["job_listing_id"]
          id = table.by_row[x]["id"]
          
          if job_listing_id.nil?
            all_ids << id
          else
            all_job_listing_ids << job_listing_id
          end
          x = x + 1;
          if(x >= table.size) 
            break
          end
        end
      end
      ans = []
      ids.each do |id|
        found = false
        all_job_listing_ids.each do |all|
          if all == id
            found = true
            break
          end
        end
        if !found
          ans << id
        end
      end
      puts ans
      puts ans.size
    end
  end
end
