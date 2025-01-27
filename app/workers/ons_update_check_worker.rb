require "rss"
require "open-uri"

class OnsUpdateCheckWorker < OnsBaseWorker
  ONSPD_RSS_URL = "https://geoportal.statistics.gov.uk/api/feed/rss/2.0?q=PRD_ONSPD&sort=Date%20Created%7Ccreated%7Cdesc".freeze

  def perform
    URI.parse(ONSPD_RSS_URL).open do |rss|
      feed = RSS::Parser.parse(rss)

      newest = feed.items.first

      if more_recent?(newest)
        new_data_url = "https://www.arcgis.com/sharing/rest/content/items/#{arcgis_item_id(newest)}/data"
        Rails.logger.info("Updated ONSPD file: #{newest.title}")
        Rails.logger.info("Starting download from #{new_data_url}")
        Import.create(url: new_data_url)
        OnsDownloadWorker.perform_async(new_data_url)
      end
    end
  end

private

  def more_recent?(item)
    return true unless Import.any?

    item.pubDate > Import.maximum(:created_at)
  end

  def arcgis_item_id(item)
    matches = item.guid.content.match(/id=(\h+)/)
    raise StandardError("OnsUpdateCheckWorker couldn't extract download item from [#{item.guid.content}]") unless matches

    matches[1]
  end
end
