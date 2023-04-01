using Matching
using Test
using UUIDs

@testset "Construction" begin
    app_a = Applicant("Gauri")
    loc_a = Location("ABC", 5)
end

@testset "Video Example 1" begin
    # This example is based on the video shown here
    # https://www.nrmp.org/intro-to-the-match/how-matching-algorithm-works/
    # Create applicants and locations
    arthur  = Applicant("Arthur")
    sunny   = Applicant("Sunny")
    joseph  = Applicant("Joseph")
    latha   = Applicant("Latha")
    darrius = Applicant("Darrius")

    mercy   = Location("Mercy", 2)
    city    = Location("City", 2)
    general = Location("General", 2)

    # Add preferences
    add_list!(arthur, [city])
    add_list!(sunny, [city, mercy])
    add_list!(joseph, [city, general, mercy])
    add_list!(latha, [mercy, city, general])
    add_list!(darrius, [city, mercy, general])

    add_list!(mercy, [darrius, joseph])
    add_list!(city, [darrius, arthur, sunny, latha, joseph])
    add_list!(general, [darrius, arthur, joseph, latha])

    # Run the algorithm
    locations  = [mercy, city, general]
    applicants = [arthur, sunny, joseph, latha, darrius]
    got        = Matching.match(locations, applicants)

    # What do we want?
    want = Dict(
        "Mercy" => Set([]),
        "City" => Set(["Darrius", "Arthur"]),
        "General" => Set(["Joseph", "Latha"]),
    )

    @test got == want
end

@testset "Video Example 2" begin
    # Based on this video
    # https://natmatch.com/ashprmp/algorithm.html

    # Create applicants and locations
    a = Applicant("Carlos")
    b = Applicant("Alisha")
    c = Applicant("Kevin")

    mountain = Location("Mountain", 2)
    bayview  = Location("Bayview", 1)
    hillside = Location("Hillside", 1)

    # Add preferences
    add_list!(a, [bayview, mountain])
    add_list!(b, [mountain, bayview, hillside])
    add_list!(c, [bayview, mountain])

    add_list!(mountain, [c, b, a])
    add_list!(bayview, [c, b, a])
    add_list!(hillside, [b])

    # Run the algorithm
    locations  = [mountain, bayview, hillside]
    applicants = [a, b, c]
    got        = Matching.match(locations, applicants)

    # What do we want?
    want = Dict(
        "Mountain" => Set(["Alisha", "Carlos"]),
        "Bayview"  => Set(["Kevin"]),
        "Hillside" => Set([]),
    )

    @test got == want
end

@testset "3x3" begin
    # Create applicants and locations
    a = Applicant("A")
    b = Applicant("B")
    c = Applicant("C")

    p1 = Location("P1", 1)
    p2 = Location("P2", 1)
    p3 = Location("P3", 1)

    # Add preferences
    add_list!(a, [p1, p2, p3])
    add_list!(b, [p1, p3, p2])
    add_list!(c, [p3, p1, p2])

    add_list!(p1, [a, b, c])
    add_list!(p2, [b, c, a])
    add_list!(p3, [c, a, b])

    # Run the algorithm
    locations  = [p1, p2, p3]
    applicants = [a, b, c]
    got        = Matching.match(locations, applicants)

    # What do we want?
    want = Dict("P1" => Set(["A"]), "P2" => Set(["B"]), "P3" => Set(["C"]))

    @test got == want
end