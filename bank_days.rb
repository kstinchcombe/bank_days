# this enables
#   Date.today + 1.bank_day
#   Date.today - 3.bank_days
# note, has to be a Date, not a DateTime etc

# h/t Jacob Rosenberg of LendUp and Zynga and Yahoo fame for
#  coining the term "Bomorrow"

# create a business days class
#  an instance of this is returned from 2.bank_days
class BankDays < Struct.new(:num_days)

  # http://www.federalreserve.gov/aboutthefed/k8.htm
  BANK_HOLIDAYS = [
    "January 1, 2014", "January 1, 2015", "January 1, 2016", "January 2, 2017", "January 1, 2018",  # New Year's Day
    "January 20, 2014", "January 19, 2015", "January 18, 2016", "January 16, 2017", "January 15, 2018",  # Birthday of Martin Luther King, Jr.
    "February 17, 2014", "February 16, 2015", "February 15, 2016", "February 20, 2017", "February 19, 2018",  # Washington's Birthday
    "May 26, 2014", "May 25, 2015", "May 30, 2016", "May 29, 2017", "May 28, 2018",  # Memorial Day
    "July 4, 2014", "July 4, 2015", "July 4, 2016", "July 4, 2017", "July 4, 2018",  # Independence Day
    "September 1, 2014", "September 7, 2015", "September 5, 2016", "September 4, 2017", "September 3, 2018",  # Labor Day
    "October 13, 2014", "October 12, 2015", "October 10, 2016", "October 9, 2017", "October 8, 2018",  # Columbus Day
    "November 11, 2014", "November 11, 2015", "November 11, 2016", "November 11, 2017", "November 12, 2018",  # Veterans Day
    "November 27, 2014", "November 26, 2015", "November 24, 2016", "November 23, 2017", "November 22, 2018",  # Thanksgiving Day
    "December 25, 2014", "December 25, 2015", "December 26, 2016", "December 25, 2017", "December 25, 2018",  # Christmas Day
  ].collect{|d| Date.parse(d)}
  
  def self.is_bank_holiday(d)
    BANK_HOLIDAYS.include?(d)
  end
  
  def self.bank_holidays
    BANK_HOLIDAYS
  end
  
  # 'bank-tomorrow' -- bomorrow
  def self.bomorrow(d, num_days=1)
    return d if num_days == 0
    increment = num_days < 0 ? -1 : 1
    num_days.abs.times do 
      d = d + increment
      while d.saturday? || d.sunday? || self.is_bank_holiday(d)
        d = d + increment
      end
    end
    return d
  end

  # 'bank-yesterday' -- besterday
  def self.besterday(d, num_days=1)
    self.bomorrow(d, 0-num_days)
  end

end

# edit Date to enable to add or subtract bank days
class Date
  alias_method :add_days_without_bank_days, :+
  def + foo
    return self.add_days_without_bank_days(foo) unless foo.is_a?(BankDays)
    return BankDays.bomorrow(self, foo.num_days)
  end
  alias_method :subtract_days_without_bank_days, :-
  def - foo
    return self.subtract_days_without_bank_days(foo) unless foo.is_a?(BankDays)
    return BankDays.besterday(self, foo.num_days)
  end
end

# edit Fixnum to allow 1.bank_days etc
class Fixnum
  def bank_days
    BankDays.new(self)
  end
  def bank_day
    BankDays.new(self)
  end
end