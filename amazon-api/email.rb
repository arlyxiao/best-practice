require 'base64'

module Email

  class << self

    def send(to_list:, subject:, body:, attachment_name: nil, attachment_data: nil, from: nil, reply_to_list: nil, cc_list: nil)
      client = Aws::SES::Client.new(
          region: '',
          access_key_id: '',
          secret_access_key: ''
      )

      if attachment_name and attachment_data
        attachment_data = Base64.encode64(attachment_data)

        raw_data_for_to_list = ''
        if to_list.present?
          to_list.each do |to|
            raw_data_for_to_list += "To: #{to}\n"
          end
        end

        raw_data_for_cc_list = ''
        if cc_list.present?
          cc_list.each do |cc|
            raw_data_for_cc_list += "CC: #{cc}\n"
          end
        end

        # reply to only support one element when it contains attachment
        # It still supports array list when it doesn't have attachment
        if reply_to_list.present?
          raw_data_for_reply_to_list = "Reply-To: #{reply_to_list.first}\n"
        end

        mime_type = Mime::Type.lookup_by_extension(File.extname(attachment_name).downcase.delete(".")) || 'attachment/zip'

        client.send_raw_email({
            destinations: to_list + cc_list,
            raw_message: {
                data: "From: #{from}\n#{raw_data_for_to_list}#{raw_data_for_cc_list}#{raw_data_for_reply_to_list}Subject: #{subject}\nMIME-Version: 1.0\nContent-type: Multipart/Mixed; boundary=\"NextPart\"\n\n--NextPart\nContent-Type: text/html\n\n#{body}\n\n--NextPart\nContent-Type: #{mime_type};\nContent-Disposition: attachment; filename=\"#{attachment_name}\"\nContent-Transfer-Encoding: base64\n\n#{attachment_data}\n\n--NextPart--",
            },
            source: from
        })
      else
        mail_message = {
            source: from,
            destination: {
                to_addresses: to_list,
                cc_addresses: cc_list
            },
            message: {
                subject: {
                    data: subject,
                    charset: 'UTF-8'
                },
                body: {
                    html: {
                        data: body,
                        charset: 'UTF-8'
                    }
                }
            },
            reply_to_addresses: reply_to_list,
            return_path: from
        }

        client.send_email(mail_message)
      end
    end

  end
end
