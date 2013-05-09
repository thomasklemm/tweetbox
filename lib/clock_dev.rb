require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

include Clockwork

every(15.minutes, 'Queuing mentions')  { TwitterWorker.schedule_mentions }
every(15.minutes, 'Queuing homes')     { TwitterWorker.schedule_homes }
every(30.minutes, 'Queuing searches')  { TwitterWorker.schedule_searches }
