# Просмотр всех возможных страниц - done
# За одно выполнение. программа должна один раз обращаться к серверу
# При отказе смотреть фильм, он сохраняется и больше никогда не показывается на протяжении запуска
# Поймать ошибку доступа

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

puts "Добрейший вечерок. Захотелось посмоть фильм?"
sleep 0.3
puts "Окей. Выбери один из #{algorithms_hash.size} алгоритмов:"

until chosen

  algorithms_hash.each do |key, value|
    puts "Алгоритм #{key}"
  end

  usr_alg = ""

  until usr_alg != "" && usr_alg <= algorithms_hash.size
    usr_alg = STDIN.gets.chomp.to_i
    usr_alg = "" if usr_alg <= 0
  end

  page_uniq = true
  count = 0

  while page_uniq do
    count += 1

    page = agent.get(algorithms_hash["#{usr_alg}"] + "&page=#{count}")
    film_snippet = page.search("//div[starts-with(@class, 'film-snippet film-snippet_in-catalogue film-snippet_type_movie')]")

    break if film_snippet.nil?

    if count == 1
      first_req = film_snippet.text[0..40]
      film_snippet_common = film_snippet
    else
      if film_snippet.text[0..40] != first_req
        film_snippet_common += film_snippet
        puts count
        break if count > 50
      else
        page_uniq = false
      end
    end
  end
  # print film_snippet_common.search("meta[itemprop='name'] @content").text.split("\n")
  # puts film_snippet_common.search("meta[itemprop='name'] @content")
  # abort

  abort "ACCESS DENIED" if film_snippet.nil?

  movie_title = film_snippet.search("meta[itemprop='name'] @content")
  movie_year_country = film_snippet.search("div[@class='film-snippet__info']").text
  movie_link = film_snippet.search("div[@class='film-snippet__media'] a @href")

  puts
  puts "========="
  puts "Фильм: #{movie_title}"
  puts "Страна: #{movie_year_country}"
  puts "Ссылка: #{movie_link}" # todo opening in a web browsers
  puts

  usr_decision = ''

  while usr_decision != 'Y' && usr_decision != "N" do
    puts "Искать другой фильм? (Y/N)"
    usr_decision = STDIN.gets.upcase.chomp
  end

  chosen = true if usr_decision == "N"
end