class Author < MotionData::ManagedObject
end

class Article < MotionData::ManagedObject
  scope :allPublished, where(:published => true)
  scope :withTitle, where( value(:title) != nil ).sortBy(:title, ascending:false)
  scope :publishedSince { |date| all.where(value(:publishedAt) > date) }
end
