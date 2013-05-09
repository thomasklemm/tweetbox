require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

include Clockwork

every(1.minute, 'Queuing mentions')  { TwitterWorker.schedule_mentions }
every(1.minute, 'Queuing homes')     { TwitterWorker.schedule_homes }
every(1.minute, 'Queuing searches')  { TwitterWorker.schedule_searches }
