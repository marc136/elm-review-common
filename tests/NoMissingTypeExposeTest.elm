module NoMissingTypeExposeTest exposing (all)

import NoMissingTypeExpose exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


all : Test
all =
    describe "NoMissingTypeExpose"
        [ describe "exposed functions" functionTests
        ]


functionTests : List Test
functionTests =
    [ test "passes when an exposed function uses an exposed type" <|
        \() ->
            """
module Happiness exposing (Happiness, toString)


type Happiness
    = Ecstatic
    | FineIGuess
    | Unhappy


toString : Happiness -> String
toString howHappy =
    "Very"
"""
                |> Review.Test.run rule
                |> Review.Test.expectNoErrors
    , test "reports when an exposed function uses a private type" <|
        \() ->
            """
module Happiness exposing (toString)


type Happiness
    = Ecstatic
    | FineIGuess
    | Unhappy


toString : Happiness -> String
toString howHappy =
    "Very"
"""
                |> Review.Test.run rule
                |> Review.Test.expectErrors
                    [ Review.Test.error
                        { message = "Private type `Happiness` used by exposed function"
                        , details =
                            [ "Type `Happiness` is used by an exposed function but is not exposed itself."
                            ]
                        , under = "Happiness"
                        }
                        |> Review.Test.atExactly { start = { row = 5, column = 6 }, end = { row = 5, column = 15 } }
                    ]
    ]
