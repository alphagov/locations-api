require "rss"

def ons_rss(last_updated: Time.zone.now)
  ons_base_rss(last_updated:, guid: "https://www.arcgis.com/home/item.html?id=abc123")
end

def broken_ons_rss(last_updated: Time.zone.now)
  ons_base_rss(last_updated:, guid: "https://www.arcgis.com/home/item.html")
end

def ons_base_rss(last_updated:, guid:)
  rss = RSS::Maker.make("2.0") do |maker|
    maker.channel.description = "ONSPD Search"
    maker.channel.updated = last_updated.to_s
    maker.channel.title = "Open Geography Portal"
    maker.channel.link = "https://geoportal.statistics.gov.uk/"

    maker.items.new_item do |item|
      item.link = "https://geoportal.statistics.gov.uk/datasets/ons::ons-postcode-directory-february-2024"
      item.title = "ONS Postcode Directory (#{last_updated.strftime('%B %Y')})"
      item.updated = last_updated.to_s
      guid_obj = RSS::Rss::Channel::Item::Guid.new(true, guid)
      guid_obj.setup_maker(item)
    end
  end

  rss.to_s
end
