import requests
import random
from faker import Faker

fake = Faker()

#using api so we have semi-realistic tv show data
BASE_URL = "https://api.tvmaze.com/shows"
NUM_SHOWS = 40

# platforms r just randomized, bc it doesn't rlly matter if it's true
platforms = [
    "Netflix", "Hulu", "Amazon Prime Video",
    "Disney+", "HBO Max", "Apple TV+",
    "Peacock", "Paramount+"
]

# to keep it semi realistic the language should match the country, and some countries have 2 languages
country_languages = {
    "United States": ["English"],
    "United Kingdom": ["English"],
    "Canada": ["English", "French"],
    "Spain": ["Spanish"],
    "France": ["French"],
    "Germany": ["German"],
    "Japan": ["Japanese"],
    "South Korea": ["Korean"],
    "India": ["Hindi", "English"],
    "Mexico": ["Spanish"],
    "Brazil": ["Portuguese"]
}

# Broader but still realistic pool for Faker to draw from
faker_language_pool = [
    "English", "Spanish", "French", "German",
    "Japanese", "Korean", "Hindi", "Portuguese", "Italian"
]

# prevent nulls being inserted
def safe_str(value, fallback=None):
    if value is None:
        value = fallback if fallback else fake.word()
    return "'" + str(value).replace("'", "''") + "'"

def safe_year(value):
    if value is None:
        return str(fake.year())
    return str(value)

def safe_runtime(value):
    if value is None:
        return str(random.choice([22, 30, 45, 60]))
    return str(value)

def safe_date(value):
    if value is None:
        return f"'{str(fake.date_between(start_date='-20y', end_date='today'))}'"
    return f"'{value}'"

def safe_int(value):
    return str(value) if value is not None else "NULL"

# getting shows but i dont want them to be boring bc im picky woo
all_shows = []

for page in range(0, 3):  # adjust for more/less variety
    data = requests.get(f"https://api.tvmaze.com/shows?page={page}").json()
    all_shows.extend(data)

# remove missing ratings
all_shows = [s for s in all_shows if s["rating"]["average"] is not None]

# sort by popularity (rating)
all_shows.sort(key=lambda x: x["rating"]["average"], reverse=True)

# take top 40
shows = all_shows[:NUM_SHOWS]

for show in shows:
    show_id = show["id"]
    title = safe_str(show["name"])

    country = "Unknown"
    if show["network"] and show["network"]["country"]:
        country = show["network"]["country"]["name"]

    start_year = show["premiered"][:4] if show["premiered"] else fake.year()

    country_sql = safe_str(country)

    status = safe_str(show["status"])

    # ---- TV_SHOW ----
    print(f"INSERT INTO Spring26_S008_T3_TV_SHOW VALUES ({show_id}, {title}, {country_sql}, {safe_year(start_year)}, {status});")

    # ---- GENRES ----
    for genre in show["genres"]:
        print(f"INSERT INTO Spring26_S008_T3_TV_SHOW_GENRE VALUES ({show_id}, {safe_str(genre)});")

    # ---- LANGUAGES (API + Faker, but controlled) ----
    langs = set()

    # Always include real API language
    if show["language"]:
        langs.add(show["language"])

    # Add country-based realistic languages
    if country in country_languages:
        langs.update(country_languages[country])

        # Faker adds variation, but ONLY within realistic options
        if random.random() < 0.3:
            extra_lang = fake.random_element(country_languages[country])
            langs.add(extra_lang)
    else:
        # fallback if country unknown (rare case)
        if random.random() < 0.3:
            extra_lang = fake.random_element(faker_language_pool)
            langs.add(extra_lang)

    for lang in langs:
        print(f"INSERT INTO Spring26_S008_T3_TV_SHOW_LANGUAGE VALUES ({show_id}, {safe_str(lang)});")

    # ---- PLATFORMS (Faker-style randomness, but controlled list) ----
    num_platforms = random.randint(1, 3)
    for platform in random.sample(platforms, num_platforms):
        print(f"INSERT INTO Spring26_S008_T3_TV_SHOW_PLATFORM VALUES ({show_id}, {safe_str(platform)});")

    # ---- SEASONS (LIMITED) ----
    seasons = requests.get(f"{BASE_URL}/{show_id}/seasons").json()

    # limit to max 3 seasons
    seasons = seasons[:3]

    for season in seasons:
        season_num = season["number"]

        release_year = (
            season["premiereDate"][:4]
            if season["premiereDate"]
            else start_year
        )

        print(f"INSERT INTO Spring26_S008_T3_SEASON VALUES ({show_id}, {season_num}, {safe_year(release_year)});")


    # ---- EPISODES (LIMITED PER SEASON) ----
    episodes = requests.get(f"{BASE_URL}/{show_id}/episodes").json()

    # group episodes by season
    season_episode_map = {}

    for ep in episodes:
        season_episode_map.setdefault(ep["season"], []).append(ep)

    # limit episodes per season
    for season_num, eps in season_episode_map.items():
        eps = eps[:5]  # max 5 episodes per season

        for ep in eps:
            ep_title = safe_str(ep["name"], fallback=fake.sentence(nb_words=3))
            runtime = safe_runtime(ep["runtime"])
            airdate = safe_date(ep["airdate"])

            ep_season = ep["season"] if ep["season"] else season_num
            ep_number = ep["number"] if ep["number"] else 1

            print(f"""INSERT INTO Spring26_S008_T3_EPISODE VALUES ({show_id}, {ep_season}, {ep_number}, {ep_title}, {runtime}, {airdate});""")