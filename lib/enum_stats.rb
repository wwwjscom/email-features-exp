#  Add methods to Enumerable, which makes them available to Array
module Enumerable
 
  #  sum of an array of numbers
  def sum
    self.inject(:+)
  end
 
  #  average of an array of numbers
  def average
    self.sum / self.length.to_f
  end
 
  #  variance of an array of numbers
  def sample_variance
    avg = self.average
    sum = self.inject(0){|acc,i|acc +(i-avg)**2}
    (1 / self.length.to_f*sum)
  end
 
  #  standard deviation of an array of numbers
  def std_dev
    Math.sqrt(self.sample_variance)
  end
 
end
