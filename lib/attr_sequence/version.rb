module AttrSequence
  module Version
    Major       = 1
    Minor       = 0
    Revision    = 0
    Prerelease  = nil
    Compact     = [Major, Minor, Revision, Prerelease].compact.join('.')
    Summary     = "AttrSequence v#{Compact}"
    Description = "An ActiveRecord concern that generates scoped sequential IDs for models."
    Author      = "Jurgen Jocubeit"
    Email       = "support@brightcommerce.com"
    Homepage    = "https://github.com/brightcommerce/attr_sequence"
    Metadata    = {'copyright' => 'Copyright 2018 Brightcommerce, Inc. All Rights Reserved.'}
    License     = "MIT"
  end
end
