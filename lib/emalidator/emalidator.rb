module Emalidator
  class Emalidator
    def initialize(main_arg: nil)
      Email.load_disposable_domains

      if main_arg.include? '@'
        Email.columns = ['email']
        @emails = [ Email.new([main_arg]) ]
      else
        @emails = read_from_file main_arg
        @valid_output_file, @invalid_output_file = output_file_names main_arg
      end

      validate
      puts statistics

      if @valid_output_file && @invalid_output_file
        File.open(@valid_output_file, 'w') do |f|
          f.write valid_emails_as_csv
        end

        File.open(@invalid_output_file, 'w') do |f|
          f.write invalid_emails_as_csv
        end
      else
        @emails.each do |email|
          puts "#{email.email} is #{email.validity}"
        end
      end
    end

    def statistics
      { 'Valid ratio': valid_emails.count.to_f/(@emails.count) }
    end

    def output_file_names(file_name)
      parts = file_name.split '.'
      return ["#{file_name}.valid.csv", "#{file_name}.invalid.csv"] if parts.length == 1
      ["#{parts[0..-2].join('.')}.valid.#{parts[-1]}", "#{parts[0..-2].join('.')}.invalid.#{parts[-1]}"]
    end

    def read_from_file(file_path)
      emails = []

      # count = 1000

      CSV.foreach(file_path) do |row|
        if Email.columns?
          emails.push Email.new row
        else
          Email.columns= row
        end

        # count -= 1
        # break unless count > 0
      end

      emails
    end

    def validate
      # bm = Benchmark.measure do
      Parallel.each(@emails, in_threads: 256) do |email|
        email.validate
      end
      # end

      # ap bm
      # byebug

      # Benchmarks for 1000 emails
      # Without threads, 1000
      # <Benchmark::Tms:0x007f8e8a172530 @label="", @real=725.9879700000165, @cstime=0.0, @cutime=0.0, @stime=0.61, @utime=1.16, @total=1.77>
      # #<Benchmark::Tms:0x007fe4936818c8 @label="", @real=15.931300999945961, @cstime=0.0, @cutime=0.0, @stime=1.48, @utime=1.42, @total=2.9>

      # Benchmarks for 10000 emails
      # 8 Threads
      # <Benchmark::Tms:0x007fd7a0e9dca0 @label="", @real=843.727011000039, @cstime=0.0, @cutime=0.0, @stime=10.489999999999998, @utime=13.33, @total=23.82>
      # 16 Threads
      # <Benchmark::Tms:0x007f928dc5eeb0 @label="", @real=380.51313799992204, @cstime=0.0, @cutime=0.0, @stime=14.82, @utime=13.5, @total=28.32>
      # 32 Threads
      # <Benchmark::Tms:0x007f9ac05f2f50 @label="", @real=232.89745399996173, @cstime=0.0, @cutime=0.0, @stime=17.23, @utime=12.52, @total=29.75>
      # 64 Threads
      # <Benchmark::Tms:0x007ff9a41029f8 @label="", @real=283.2102500000037, @cstime=0.0, @cutime=0.0, @stime=17.830000000000002, @utime=12.219999999999999, @total=30.05>
      # 128 Threads
      # <Benchmark::Tms:0x007fc45eddd950 @label="", @real=161.36441799998283, @cstime=0.0, @cutime=0.0, @stime=32.19, @utime=12.76, @total=44.949999999999996>
      # 256 Threads
      # <Benchmark::Tms:0x007f8fdc2637c0 @label="", @real=146.32397600007243, @cstime=0.0, @cutime=0.0, @stime=69.38000000000001, @utime=14.42, @total=83.80000000000001>
      # 512 Threads
      # <Benchmark::Tms:0x007fb5a4158b58 @label="", @real=161.33898700005375, @cstime=0.0, @cutime=0.0, @stime=86.00999999999999, @utime=17.290000000000003, @total=103.3>
    end

    def valid_emails_as_csv
      emails_as_csv valid_emails
    end

    def invalid_emails_as_csv
      emails_as_csv invalid_emails, include_error: true
    end

    def emails_as_csv(emails, include_error: false)
      ([Email.columns_csv(include_error: include_error)] + emails.map { |email| email.to_csv }).join "\n"
    end

    def valid_emails
      @emails.select(&:emalidator_valid)
    end

    def invalid_emails
      @emails.reject(&:emalidator_valid)# .map do |email|
      #   [email.email, email.emalidator_errors.first].join ' | '
      # end
    end
  end
end
