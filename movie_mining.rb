require 'mechanize'
require 'json'

file_path = File.dirname(__FILE__)
algorithms_file = file_path + "/algorithm.json"

begin
  algorithms_data = File.read (algorithms_file)
rescue Errno::ENOENT
  abort "ERROR DOWNLOAD ALGORITHMS"
end

algorithms_hash = JSON.parse(algorithms_data)

agent = Mechanize.new()

chosen = false

until chosen
  puts "Добрейший вечерок. Захотелось посмоть фильм?"
  sleep 0.3
  puts "Окей. Выбери один из #{algorithms_hash.size} алгоритмов:"

  algorithms_hash.each do |key, value|
    puts "Алгоритм #{key}"
  end

  usr_alg = ""

  until usr_alg != "" && usr_alg <= algorithms_hash.size
    usr_alg = STDIN.gets.chomp.to_i
    usr_alg = "" if usr_alg <= 0
  end

  page = agent.get(algorithms_hash["#{usr_alg}"])
  film_snippet = page.search("//div[starts-with(@class, 'film-snippet film-snippet_in-catalogue film-snippet_type_movie')]").to_a.sample

  abort "ACCESS DENIED" if film_snippet.nil?

  movie_title = film_snippet.search("meta[itemprop='name'] @content")
  movie_year_country = film_snippet.search("div[@class='film-snippet__info']").text
  movie_link = film_snippet.search("div[@class='film-snippet__media']")
  print movie_link
  abort

  a = STDIN.gets

end