class Author < MotionData::ManagedObject
end

class Article < MotionData::ManagedObject
  scope :published, where(:published => true)
  scope :withTitle, where( value(:title) != nil ).sortBy(:title, ascending:false)
end
