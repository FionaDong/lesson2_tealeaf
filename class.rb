class A
	attr_accessor :a
	def initialize(a)
		@a = a
	end
	def to_s
		puts "#{a}"
	end
end

a = A.new(3)



