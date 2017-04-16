class Account < ApplicationRecord
  belongs_to :user
  has_many :balance_record_sets
  has_many :account_imports

  # Cannot conflict with SummaryController::NET_WORTH_COLOR
  def self.valid_colors
    [
      "cornflowerblue",
      "crimson",
      "cyan",
      "darkcyan",
      "darkgoldenrod",
      "darkgreen",
      "darkkhaki",
      "darkmagenta",
      "darkorange",
      "darkred",
      "darksalmon",
      "darkseagreen",
      "darkviolet",
      "deeppink",
      "darkgrey",
      "greenyellow",
      "lemonchiffon",
      "lightblue",
      "orchid",
      "palevioletred"
    ]
  end

  validates :name, presence: true, allow_blank: false
  validates :color, inclusion: { in: Account.valid_colors }

  before_validation :assign_color, on: :create

  def assign_color
    if color.nil?
      colors_left = self.class.valid_colors - user.accounts.pluck(:color)

      if colors_left.none?
        errors.add(:base, "The maximum number of accounts has been exceeded.  Please contact support to have your limit raised.")
      else
        self.color = colors_left.first
      end
    end
  end

  private

  def tracking_params
    { user_id: user.id }
  end
end
