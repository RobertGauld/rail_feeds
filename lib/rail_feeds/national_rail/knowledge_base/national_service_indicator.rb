# frozen_string_literal: true

module RailFeeds
  module NationalRail
    module KnowledgeBase
      # A module for accessing the national service indicator
      # from the national rail  knowledge base.
      module NationalServiceIndicator
        TOC = Struct.new(
          :code, :name, :status, :twitter_account, :additional_info, :service_groups
        ) do
          def to_s
            "#{code} - #{name}\n" \
            "#{status}\n#{service_groups.join("\n")}\n" \
            "@#{twitter_account} - #{additional_info}"
          end
        end

        Status = Struct.new(:title, :description, :image) do
          def to_s
            "#{title} - #{description} - #{image}"
          end
        end

        ServiceGroup = Struct.new(:disruption_id, :name, :detail, :url) do
          def to_s
            "#{name} - #{detail}\n#{disruption_id} #{url}"
          end
        end

        # Download the current data.
        # @param [RailFeeds::NationalRail::Credentials] credentials
        # @param [String] file
        #   The path to the file to save the .xml download in.
        def self.download(file, credentials = Credentials)
          client = HTTPClient.new(credentials: credentials)
          client.download 'darwin/api/staticfeeds/4.0/serviceIndicators', file
        end

        # Fetch the current data.
        # @param [RailFeeds::NationalRail::Credentials] credentials
        # @return [IO]
        def self.fetch(credentials = Credentials, &block)
          client = HTTPClient.new(credentials: credentials)
          client.fetch 'darwin/api/staticfeeds/4.0/serviceIndicators', &block
        end

        # Load data from either a .json or .json.gz file.
        # @param [String] file The path of the file to open.
        # @return
        #   [Array<RailFeeds::NationalRail::KnowledgeBase::NationalServiceIndicator::TOC>]
        def self.load_file(file)
          parse_xml File.read(file)
        end

        # Load data from the internet.
        # @param [RailFeeds::NationalRail::Credentials] credentials
        #  The credentials to authenticate with.
        # @return
        #   [Array<RailFeeds::NationalRail::KnowledgeBase::NationalServiceIndicator::TOC>]
        def self.fetch_data(credentials = Credentials)
          fetch(credentials: credentials) do |file|
            parse_xml file.read
          end
        end

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        def self.parse_xml(xml)
          options = Nokogiri::XML::ParseOptions.new.nonet.noent.noblanks
          doc = Nokogiri::XML.parse(xml, nil, nil, options)
          doc.xpath('/xmlns:NSI/xmlns:TOC').map do |toc_node|
            TOC.new(
              toc_node.xpath('./xmlns:TocCode').first&.content,
              toc_node.xpath('./xmlns:TocName').first&.content,
              Status.new(
                toc_node.xpath('./xmlns:Status').first&.content,
                toc_node.xpath('./xmlns:StatusDescription').first&.content,
                toc_node.xpath('./xmlns:StatusImage').first&.content
              ),
              toc_node.xpath('./xmlns:TwitterAccount').first&.content,
              toc_node.xpath('./xmlns:AdditionalInfo').first&.content,
              toc_node.xpath('./xmlns:ServiceGroup').map do |service_group|
                ServiceGroup.new(
                  service_group.xpath('./xmlns:CurrentDisruption').first&.content,
                  service_group.xpath('./xmlns:GroupName').first&.content,
                  service_group.xpath('./xmlns:CustomDetail').first&.content,
                  service_group.xpath('./xmlns:CustomURL').first&.content
                )
              end
            )
          end
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength
        private_class_method :parse_xml
      end
    end
  end
end
