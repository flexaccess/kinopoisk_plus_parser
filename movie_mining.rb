# Просмотр всех возможных страниц - done
# За одно выполнение. программа должна один раз обращаться к серверу
# При отказе смотреть фильм, он сохраняется и больше никогда не показывается на протяжении запуска
# Поймать ошибку доступа

# Mechanize::Page

require 'mechanize'
require 'json'
require 'date'

date = Date.today

def transformator(*params)

  def get_new_element_to_hash(new_element, arry, name_hash)
    count = 0
    arry_size = arry.size

    new_element.each do |item_new_element|
      arry[count][name_hash] = item_new_element.text.to_s
      count += 1
      break if count >= arry_size
    end

    return arry
  end

  arry = []
  i = 1

  loop do
    arry << {}
    i += 1
    break if i > params[0].size
  end

  count = 1

  params.each do |param|
    get_new_element_to_hash(param, arry, ("param" + count.to_s).to_sym)
    count += 1
  end
  
  return arry
end

file_path = File.dirname(__FILE__)
algorithms_file = file_path + "/algorithm.json"

begin
  algorithms_data = File.read (algorithms_file)
rescue Errno::ENOENT
  abort "ERROR DOWNLOAD ALGORITHMS"
end

algorithms_hash = JSON.parse(algorithms_data)
# random_alhoritm = rand(algorithms_hash.size) + 1
random_alhoritm = 4

agent = Mechanize.new()

puts "Добрейший вечерок. Захотелось посмоть фильм?"
sleep 0.3
puts "Окей, я выбрал случайный алгоритм: #{random_alhoritm}"

puts 'Теперь нужно првоерить, есть ли файл с этим алгоритмом?'

film_by_alhoritm = file_path + "/films/#{random_alhoritm}.json"

if File.exist?(film_by_alhoritm)
  puts 'Да, такой файл есть.'
  puts 'А если есть файл, то тогда нам нужно проверить актуальны ли там данные?'

  f = File.new(film_by_alhoritm, 'r:UTF-8')
  content = f.read
  f.close

  content = JSON.parse(content)
  file_date = content['date']

  file_date = Date.strptime(file_date, '%F')
  subtr_date = (date - file_date).to_i

  if subtr_date < 7 + random_alhoritm

    puts 'Да, дата в порядке, можно выбирать случайный фильм!'

  else

    puts 'Нет, с датой беда, слишком старая, нужно парсить по новой!'

  end

else
  puts 'Нет, такого файла нет. И тоже нужно парсить по новой!'
end

abort

page_uniq = true
count = 0

# while page_uniq do
#   count += 1

#   page = agent.get(algorithms_hash["#{random_alhoritm}"] + "&page=#{count}")
#   film_snippet = page.search("//div[starts-with(@class, 'film-snippet film-snippet_in-catalogue film-snippet_type_movie')]")

#   break if film_snippet.nil?

#   if count == 1
#     first_req = film_snippet.text[0..40]
#     film_snippet_common = film_snippet
#   else
#     if film_snippet.text[0..40] != first_req
#       film_snippet_common += film_snippet
#       puts count
#       break if count > 50
#     else
#       page_uniq = false
#     end
#   end
# end

page = agent.get(algorithms_hash["#{random_alhoritm}"] + "&page=#{count}")
film_snippet = page.search("//div[starts-with(@class, 'film-snippet film-snippet_in-catalogue film-snippet_type_movie')]")


title =         film_snippet.search("meta[itemprop='name'] @content")
year_country =  film_snippet.search("div[@class='film-snippet__info']")
link =          film_snippet.search("div[@class='film-snippet__media'] a @href")
img =           film_snippet.search("img.image @src")

abort "\nERROR: Big Dick\n\n" if film_snippet.empty?

films = transformator(title, year_country, link, img) # здесь мы получаем большой массив с рассорированными параметрами

hash_films = {date: date.strftime("%F"), data: films}

f = File.new(film_by_alhoritm, 'w')
f.puts(hash_films.to_json)
f.close

puts 'Окей, я записал все спарсенное в файл.'
abort