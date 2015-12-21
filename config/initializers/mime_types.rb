# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

MIME::Types.add MIME::Type.new('text/x-python') { |t| t.add_extensions 'py' }
MIME::Types.add MIME::Type.new('text/x-ruby') { |t| t.add_extensions 'rb' }
