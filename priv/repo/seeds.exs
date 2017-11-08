# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Kami.Repo.insert!(%Kami.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

{_, admin} = Kami.Accounts.create_admin(%{name: "admin", password: "password"})

Kami.Accounts.create_character(admin, %{name: "Teakwood", family: "Codefloof", image: ""})

{_, lobby} = Kami.World.create_location(%{name: "Lobby", description: "OOC Discussion", locked: false, ooc: true})
{_, sessions} = Kami.World.create_location(lobby, %{name: "Session Rooms", description: "Session Rooms", locked: true, ooc: true})
Kami.World.create_location(sessions, %{name: "Session Room 1", description: "Session Room 1", locked: false, ooc: false})
Kami.World.create_location(sessions, %{name: "Session Room 2", description: "Session Room 2", locked: false, ooc: false})
Kami.World.create_location(sessions, %{name: "Session Room 3", description: "Session Room 3", locked: false, ooc: false})
Kami.World.create_location(sessions, %{name: "Session Room 4", description: "Session Room 4", locked: false, ooc: false})
{_, toshi} = Kami.World.create_location(lobby, %{name: "Toshi Tenjikobutan", description: "-", locked: true, ooc: true})
{_, shiro} = Kami.World.create_location(toshi, %{name: "Shiro Yanagi", description: "-", locked: true, ooc: true})
Kami.World.create_location(shiro, %{name: "Shiro Yanagi Court Room", description: "-", locked: false, ooc: false})
{_, garden} = Kami.World.create_location(shiro, %{name: "The Garden of Elegant Things", description: "-", locked: true, ooc: true})
Kami.World.create_location(garden, %{name: "In Spring, Dawn", description: "Facing due east, the spring garden welcomes the sun each morning, red and golden lines bursting over the top of granite stones that in the glare look like the peaks of distant mountains. The first rays of light cast no shadows, perfectly glazing the open air dojo nestled in the center of the garden. Orderly paths take visitors through a progression of the season, from barren rocks that catch the last snow to fields of the first pale flowers of the strawberries, carpets of glowing pink phlox, and finally bright yellow nanohana blooms that skirt the dojo. The garden’s exterior walls are ringed in alternating plum and cherry, which in late spring are said to soften even the sternest bushi with their beauty.", locked: false, ooc: false})
Kami.World.create_location(garden, %{name: "In Summer, Night", description: "The sun never shines in the summer garden, a carefully tangled wilderness of trees and vines. Positioned in the north, Shiro Yanagi covers the garden in perpetual shade. After sunset, every plant in the garden blooms, drawing soft-voiced thrushes and nightingales from their beds. Lanterns are hung at seemingly careless intervals along winding paths, hinting at corners where visitors have strayed. Adventurous samurai may find long, warmly colored sandstone benches hidden under lush night-blooming jasmine, inviting lingering moments of stillness. At the center of the garden is an arbor trellised with sprawling, eager wisteria that has swallowed any trace of human touch under a cascade of violet flowers.", locked: false, ooc: false})
Kami.World.create_location(garden, %{name: "In Autumn, Evening", description: "The reflection of the spring garden, the autumn garden faces due west to catch the setting sun. In the center are granite stones that echo those in the spring garden; here water flows down their faces to form a gliding pool where golden koi flash and bubble just below the surface. Willows and maples and bamboo huddle together in the chilled wind, rattling like fall insects before their long sleep. Intimate wood tables welcome visitors to enjoy a game of shogi or a cup of warm sake in the dying light.", locked: false, ooc: false})
Kami.World.create_location(garden, %{name: "In Winter, Early Morning", description: "Winter: the southern garden, where the sun shines but nothing grows. There are no flowers or benches or paths, only barren rocks and naked trees and, in the center, an ornate brazier kept glowing at every hour. A perpetual layer of white blankets the garden: snow in the deep cold, otherwise perfectly white ash, both carrying report for a few hours of those who lingered there last and smoothed twice daily by the flat rakes of silent gardeners.", locked: false, ooc: false})
Kami.World.create_location(garden, %{name: "The Void Ring", description: "The four seasonal gardens are ringed by a fifth garden, this one only five feet wide and bounded on each side by tall white walls. The walls are set with four twinned archways through which paths run to each other garden. The air in the Void Garden hangs motionless, neither stifling nor comfortable. There is little space and less sweetness in lingering; even the gardeners pass quickly through the archways.", locked: false, ooc: false})
{_, north} = Kami.World.create_location(shiro, %{name: "North Yashiki", description: "-", locked: true, ooc: true})
Kami.World.create_location(north, %{name: "Crane Quarters", description: "-", locked: false, ooc: false})
Kami.World.create_location(north, %{name: "Scorpion Quarters", description: "-", locked: false, ooc: false})
Kami.World.create_location(north, %{name: "Onsen Bath House", description: "The bath house is strictly conservative, divided by a sturdy wall into men’s and women’s sides, though conversation over the wall is possible. An attendant enforces perfect adherence to etiquette, shuffling men and women to the proper changing rooms. The baths are continually fed from a natural hot spring. The smell is sweeter than expected; only a whiff of sulphur covers salt, skin, and sweat.", locked: false, ooc: false})
{_, west} = Kami.World.create_location(shiro, %{name: "West Yashiki", description: "-", locked: true, ooc: true})
Kami.World.create_location(west, %{name: "Dragon Quarters", description: "-", locked: false, ooc: false})
Kami.World.create_location(west, %{name: "Phoenix Quarters", description: "-", locked: false, ooc: false})
Kami.World.create_location(west, %{name: "Manzuko Temple", description: "“You cannot live while hiding from life.” Upon entering the temple, one would be forgiven for confusing it for a very different part of town. Luxurious silks hang from the walls and delicate incense burns a haze of of peace and relaxation. In the center of the room is a wooden podium supporting a plain and aged copy of the Tao, while around it against the exterior walls are elaborate shrines to each Fortune with tatami mats and offerings at their feet. The shrine to Benten, Fortune of Romantic Love, is taller far than the rest and covered in a deep drift of expensive offerings. The abbot of the temple, Togashi Yosei, is usually present with a smile and cups of steaming tea.", locked: false, ooc: false})
{_, east} = Kami.World.create_location(shiro, %{name: "East Yashiki", description: "-", locked: true, ooc: true})
Kami.World.create_location(east, %{name: "Lion Quarters", description: "-", locked: false, ooc: false})
Kami.World.create_location(east, %{name: "Unicorn Quarters", description: "-", locked: false, ooc: false})
Kami.World.create_location(east, %{name: "Horse's Joy Stables and Arena", description: "The Yanagi stables and riding arena are in slight disrepair. Some Yanagi scion lost to memory clearly once cared for horses; there are three dozen stalls over which the remains of bright paint now peel into dust. But even now there is fresh straw and millet, evidence perhaps of basic courtesy to visiting samurai more than any true affection.", locked: false, ooc: false})
{_, south} = Kami.World.create_location(shiro, %{name: "South Yashiki", description: "-", locked: true, ooc: true})
Kami.World.create_location(south, %{name: "Crab Quarters", description: "-", locked: false, ooc: false})
Kami.World.create_location(south, %{name: "Imperial Quarters", description: "-", locked: false, ooc: false})
Kami.World.create_location(south, %{name: "Season's Blessings Dojo", description: "The Season’s Blessing is the only samurai dojo in Toshi Tenjikobutan, a city few visit for any reason but pleasure. It bears clear signs of neglect, as it belongs to neither School nor sensei and as, on fine days, the Yanagi bushi prefer to drill in the spring garden Nevertheless, Season’s Blessings offers space for all samurai to train at their leisure. The practice mats are worn but serviceable, a handful of training weapons line the walls, and small charcoal braziers give a meager but pleasant warmth.", locked: false, ooc: false})
{_, dahlia} = Kami.World.create_location(toshi, %{name: "Red Dahlia District", description: "-", locked: false, ooc: false})
Kami.World.create_location(dahlia, %{name: "Street of Makers", description: "-", locked: false, ooc: false})
Kami.World.create_location(dahlia, %{name: "Midsummer Darkness Pavilion", description: "-", locked: false, ooc: false})
Kami.World.create_location(dahlia, %{name: "Fallen Petals Tea Room", description: "-", locked: false, ooc: false})
Kami.World.create_location(dahlia, %{name: "Public Market", description: "-", locked: false, ooc: false})
{_, outside} = Kami.World.create_location(lobby, %{name: "Outside the Walls", description: "-", locked: true, ooc: true})
Kami.World.create_location(outside, %{name: "Burakumin Encampment", description: "-", locked: false, ooc: false})
Kami.World.create_location(outside, %{name: "Tenjikobutan March", description: "-", locked: false, ooc: false})
Kami.World.create_location(outside, %{name: "The Farmlands", description: "-", locked: false, ooc: false})
