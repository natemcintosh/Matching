module Matching
using UUIDs

export Applicant, Location, add_location!, add_list!, match

mutable struct Location
    name    :: String
    id      :: UUID
    n_spots :: Int
    desired :: Vector{UUID}
    actual  :: Vector{UUID}
end

function Location(name::AbstractString, n_spots::Integer)
    Location(name, uuid1(), n_spots, UUID[], UUID[])
end

mutable struct Applicant
    name :: String
    id   :: UUID
    list :: Vector{UUID}
end

Applicant(name::AbstractString) = Applicant(name, uuid1(), UUID[])

"""
If there is already an item at the location of `rank`, then it will be pushed down.
If there are fewer than `rank` items already in the list, it will be put at the
bottom of the list
"""
function add_location!(person::Applicant, location::Location, rank::Int)
    if isempty(person.list)
        push!(person.list, location.id)
    else
        insert!(person.list, rank, location.id)
    end
end

"""
    add_list!(person::Applicant, list::Vector{Location})

This will set the list of locations for a given person, overwriting anything
already in the list.
The first item in the list is top ranked and the last item is last ranked.
"""
function add_list!(person::Applicant, list::Vector{Location})
    person.list = [loc.id for loc in list]
end

"""
    add_list!(location::Location, list::Vector{Applicant})

This will set the list of applications for a given location, overwriting anything
already in the list.
The first item in the list is top ranked and the last item is last ranked.
"""
function add_list!(location::Location, list::Vector{Applicant})
    location.desired = [app.id for app in list]
end

"""
Run the matching algorithm. The `actual` field of the locations will be filled.
"""
function match(locations::Vector{Location}, applicants::Vector{Applicant})
    locs = deepcopy(locations)
    apps = deepcopy(applicants)
    # Handy for lookups
    loc_d    = Dict(l.id => l for l in locs)
    person_d = Dict(p.id => p for p in apps)

    # For each applicant
    while !isempty(apps)
        person = pop!(apps)
        # For each spot on their list
        for loc_id in person.list
            location = loc_d[loc_id]

            # If not in location's desired list
            if person.id ∉ location.desired
                continue
            end

            # Get the ranks of people in location's `actual`
            ranks_in_actual =
                sort([findfirst(==(id), location.desired) for id in location.actual])

            # Where does this person rank in desired rankings?
            person_rank = findfirst(==(person.id), location.desired)

            # If this person is below the number of spots available, continue
            spot_in_actual = searchsortedfirst(ranks_in_actual, person_rank)

            if spot_in_actual > location.n_spots
                continue
            end

            # If this person fits in, and no one needs to be bumped
            # put their UUID in the correct place in this location's `actual`
            if length(location.actual) + 1 <= location.n_spots
                insert!(loc_d[loc_id].actual, spot_in_actual, person.id)
            else
                # Someone is getting bumped
                # Insert this person, then get the last person from this location's 
                # `actual`, and push them to `apps`
                insert!(loc_d[loc_id].actual, spot_in_actual, person.id)
                push!(apps, person_d[pop!(loc_d[loc_id].actual)])
            end

            # The person has tentatively matched, break out of this loop
            break
        end
    end
    Dict(l.name => Set([person_d[pid].name for pid in l.actual]) for l in locs)
end

end # module
