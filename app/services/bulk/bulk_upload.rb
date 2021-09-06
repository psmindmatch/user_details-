module Bulk 
  class BulkUpload
    def initialize(file)
       @file = file
    end

    def process
      uploaded_file = @file

      doc = File.open(Rails.root.join('public', "jobsinnetwork_index.xml")) { |f| Nokogiri::XML(f) }
      
      x = 0
      batch_size = 1000
      ids = []
      doc.css('job').each do |node|
        children = node.children
        ids <<  node.at_xpath('.//referencenumber').text # will extract cdata bloack
        x += 1
      end

      table = CSV.parse(File.read(Rails.root.join('public', uploaded_file.original_filename)), headers: true) 
      x = 0
      batch_size = 1000
      all_job_listing_ids = []
      all_ids = []
      
      while x < (table.size) 
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

      #inserting new job_listing_id in all_job_listing_ids which is missing in active csv file.
      x = 0
      table2 = CSV.parse(File.read(Rails.root.join('public', 'new_jl_ids.csv')), headers: true) 
      while x < (table2.size) 
          job_listing_id = table2.by_row[x]["job_listing_id"]
          all_job_listing_ids << job_listing_id
          x += 1;
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
