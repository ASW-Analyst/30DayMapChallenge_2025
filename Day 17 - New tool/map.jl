using CSV
using DataFrames
using Plots
using GLMakie
using GLMakie: scatter!, lines!, Figure, Axis
GLMakie.activate!() 

using Tyler
using Tyler.TileProviders
using Tyler.MapTiles
using Tyler.Extents
using Colors: distinguishable_colors

clubs = CSV.read("Day 17 - New tool/data/scottish_football_clubs.csv", DataFrame)

@show first(clubs, 5) 
lon = clubs.long
lat = clubs.lat

pad = 0.5
extent = Rect2f(
    float(minimum(lon) - pad),
    float(minimum(lat) - pad),
    float((maximum(lon) - minimum(lon)) + 2pad),
    float((maximum(lat) - minimum(lat)) + 2pad),
)

prov = TileProviders.CartoDB(:Positron)
fig = Figure(resolution = (900, 700))
ax  = Axis(fig[1, 1], title = "Location of Scottish Football Teams - Top 4 Tiers")

m = Tyler.Map(extent; provider = prov, figure = fig, axis = ax)

to_web_mercator(lon, lat) =
    Point2f(MapTiles.project((lon, lat), MapTiles.wgs84, MapTiles.web_mercator))
pts = to_web_mercator.(clubs.long, clubs.lat)

leagues = unique(clubs.league)
league_colors = Dict(
    "Scottish Premier League" => "#407EC9",
    "Scottish Championship" => "#6CC24A",
    "Scottish League One"  => "#F68D2E",
    "Scottish League Two"  => "#8A1538"
)
pt_colors = [league_colors[clubs.league[i]] for i in 1:nrow(clubs)]

scatter!(m.axis, pts;
         color      = pt_colors,
         markersize = 8,
         marker     = :circle)

legend_leagues = collect(leagues)
legend_entries = [
    MarkerElement(color = league_colors[l], marker = :circle)
    for l in legend_leagues
]
axislegend(
    m.axis,
    legend_entries,
    String.(legend_leagues),
    "League";
    position = :rt
)

hidedecorations!(ax)
hidespines!(ax)

fig