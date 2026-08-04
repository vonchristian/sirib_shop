# Generates human-friendly sequential document numbers, retrying on the rare
# collision so the database uniqueness constraint never blocks a save.
module NumberGenerator
  def self.generate(prefix, model)
    retries = 0
    begin
      date = Time.current.strftime("%Y%m%d")
      count = model.unscoped.where("number LIKE ?", "#{prefix}#{date}-%").count + 1
      "#{prefix}#{date}-#{count.to_s.rjust(4, "0")}"
    rescue ActiveRecord::RecordNotUnique
      retries += 1
      retry if retries < 3
      raise
    end
  end
end
