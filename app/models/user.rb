require 'digest'
class User < ActiveRecord::Base
  attr_accessor :password
  validates :email, uniqueness: true, length: {within: 5..50},
            format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  validates :password, confirmation: true, length: {within: 4..20}
  validates_presence_of :password, :if => :password_required?


  has_one :profile
  has_many :articles, -> { order('published_at DESC, title ASC') },
           dependent: :destroy
  has_many :replies, through: :articles, source: :comments

  before_save :encrypt_new_password

  def self.authenticate(email, password)
    user = find_by_email(email)
    return user if user && user.authenticated?(password)
  end

  def authenticated?(password)
    self.hashed_password == encrypt(password)
  end

  private
  def encrypt_new_password
    return if password.blank?
    self.hashed_password = encrypt(password)
  end

  def password_required?
    hashed_password.blank? || password.present?
  end

  def encrypt(string)
    Digest::SHA1.hexdigest(string)
  end
end
