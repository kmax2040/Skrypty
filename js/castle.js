player.onChat("clearArea", function() {
    clearArea()
})

// Please stand still when executing this command
player.onChat("castle", function() {
    // +X - east
    // -X - west
    // +Z - north
    // -Z - south

    const towerPositions = [
        pos(-8, 0,-8), // south-west
        pos( 8, 0,-8), // south-east
        pos( 8, 0, 8), // north-east
        pos(-8, 0, 8)  // north-west
    ]

    for (let i = 0; i < 2; ++i) {
        castleTower(towerPositions[i], 9, "roof")
        castleTowerFloor(towerPositions[i], 4)
    }

    for (let i = 2; i < 4; ++i) {
        castleTower(towerPositions[i], 9)
        castleTowerFloor(towerPositions[i], 4)
    }

    castleWindow(pos( -8, 6,-10))
    castleWindow(pos(-10, 6, -8))
    castleWindow(pos(  8, 6,-10))
    castleWindow(pos( 10, 6, -8))

    castleWindow(pos( -8, 6, 10))
    castleWindow(pos(-10, 6,  8))
    castleWindow(pos(  8, 6, 10))
    castleWindow(pos( 10, 6,  8))

    castleTowerLadder(pos(-7, 0,-9), 10, "south")
    castleTowerLadder(pos( 7, 0,-9), 10, "south")
    castleTowerLadder(pos(-7, 0, 9), 10, "north")
    castleTowerLadder(pos( 7, 0, 9), 10, "north")

    castleWall(pos(-8, 0, 0), 6, Axis.Z, 4)
    castleWall(pos( 8, 0, 0), 6, Axis.Z, 4)
    castleWall(pos( 0, 0,-8), 6, Axis.X, 4)
    castleWall(pos( 0, 0, 8), 6, Axis.X, 4)

    // tower entrance
    blocks.fill(Block.Air, pos(-7, 0,-7), pos(-6, 1,-6))
    blocks.fill(Block.Air, pos( 7, 0,-7), pos( 6, 1,-6))
    blocks.fill(Block.Air, pos(-7, 0, 7), pos(-6, 1, 6))
    blocks.fill(Block.Air, pos( 7, 0, 7), pos( 6, 1, 6))

    castleGate(pos(0, 0,-8))

    castleFosse(pos(-20, 0, -20), pos(20, 0, 20))

    bridge(pos(0,0,-20))

    player.say("Done!")
})

function clearArea() {
    blocks.fill(Block.Air, pos(-25, 0, -25), pos(25, 10, 25))
    blocks.fill(Block.Air, pos(-25, 10, -25), pos(25, 20, 25))
    blocks.fill(Block.Dirt, pos(-25, -5, -25), pos(25, -2, 25))
    blocks.fill(Block.Grass, pos(-25, -1, -25), pos(25, -1, 25))
    // blocks.place(Block.Bedrock, pos(0, -1, 0))
}

function castleTower(origin: Position, height: number, variant: null | "roof" = null) {
    if (height <= 0) return;

    --height

    const walls = [
        {
            a: {x:-2, z:-1},
            b: {x:-2, z: 1}
        }, {
            a: {x: 2, z:-1},
            b: {x: 2, z: 1}
        }, {
            a: {x:-1, z: 2},
            b: {x: 1, z: 2}
        }, {
            a: {x:-1, z:-2},
            b: {x: 1, z:-2}
        }
    ]

    for (const wall of walls) {
        blocks.fill(Block.StoneBricks,
            origin.add(pos(wall.a.x, 0, wall.a.z)),
            origin.add(pos(wall.b.x, height, wall.b.z))
        )
    }

    switch (variant) {
        case "roof":
            castleTowerTopRoof(pos(origin.getValue(Axis.X), height+1, origin.getValue(Axis.Z)))
        break;
        default:
            castleTowerTopNormal(pos(origin.getValue(Axis.X), height+1, origin.getValue(Axis.Z)))
        break;            
    }
}

function castleTowerFloor(origin: Position, yOffset: number = 0) {
    blocks.fill(Block.PlanksOak,
        origin.add(pos(-1, yOffset,-1)),
        origin.add(pos( 1, yOffset, 1))
    )
}

function castleTowerTopHelper(origin: Position, height: number) {
    const walls = [
        { // west
            a: {x:-3, z:-1},
            b: {x:-3, z: 1}
        },
        { // east
            a: {x: 3, z:-1},
            b: {x: 3, z: 1}
        },
        { // south
            a: {x:-1, z:-3},
            b: {x: 1, z:-3}
        },
        { // north
            a: {x:-1, z: 3},
            b: {x: 1, z: 3}
        }
    ]

    const pillars = [
        {x:-2, z:-2},
        {x: 2, z:-2},
        {x:-2, z: 2},
        {x: 2, z: 2}
    ]

    const bottomWalls = [
        blocks.blockWithData(Block.StoneBrickStairs, 4), // east upside down
        blocks.blockWithData(Block.StoneBrickStairs, 5), // west upside down
        blocks.blockWithData(Block.StoneBrickStairs, 6), // north upside down
        blocks.blockWithData(Block.StoneBrickStairs, 7)  // south upside down
    ]

    if (height <= 0) return {walls, pillars}

    --height

    shapes.circle(
        Block.PlanksOak,
        origin,
        3, 
        Axis.Y,
        ShapeOperation.Replace
    )

    let i = 0
    for (const wall of walls) {
        blocks.fill(bottomWalls[i],
            origin.add(pos(wall.a.x, 0, wall.a.z)),
            origin.add(pos(wall.b.x, 0, wall.b.z))
        )
        blocks.fill(Block.StoneBricks,
            origin.add(pos(wall.a.x, 1, wall.a.z)),
            origin.add(pos(wall.b.x, height, wall.b.z))
        )
        ++i
    }

    for (const pillar of pillars) {
        blocks.fill(Block.StoneBricks,
            origin.add(pos(pillar.x, 0, pillar.z)),
            origin.add(pos(pillar.x, height, pillar.z))
        )
    }

    return {walls, pillars}
}

function castleTowerTopNormal(origin: Position) {
    const height = 2
    const {walls, pillars} = castleTowerTopHelper(origin, height)

    for (const wall of walls) {
        blocks.place(Block.StoneBricksSlab,
            origin.add(pos(wall.a.x, height, wall.a.z))
        )

        blocks.place(Block.StoneBricksSlab,
            origin.add(pos(wall.b.x, height, wall.b.z))
        )
    }
}

function castleTowerTopRoof(origin: Position) {
    const height = 5
    const {walls, pillars} = castleTowerTopHelper(origin, height)

    // windows

    const windowPositions = [
        origin.add(pos( 3, 2, 0)),
        origin.add(pos(-3, 2, 0)),
        origin.add(pos( 0, 2, 3)),
        origin.add(pos( 0, 2,-3))
    ]

    for (let windowPos of windowPositions) {
        blocks.place(Block.Air, windowPos)
        blocks.place(Block.Air, windowPos.add(pos(0, 1, 0)))
    }

    // roof

    origin = origin.add(pos(0, height-1, 0))

    let xOffset = 2
    let zOffset = 1
    let radius = 4

    const stairs = {
        east: blocks.blockWithData(Block.OakWoodStairs, 0),
        west: blocks.blockWithData(Block.OakWoodStairs, 1),
        north: blocks.blockWithData(Block.OakWoodStairs, 2),
        south: blocks.blockWithData(Block.OakWoodStairs, 3)
    }

    for (let i = 0; i < 2; ++i) {
        let posA = origin.add(pos(-xOffset, i, radius))
        let posB = origin.add(pos( xOffset, i, radius))
        blocks.fill(stairs.south, posA, posB)
        blocks.place(stairs.south, posA.add(pos(-1, 0,-1)))
        blocks.place(stairs.south, posA.add(pos(-2, 0,-2)))
        blocks.place(stairs.south, posB.add(pos( 1, 0,-1)))
        blocks.place(stairs.south, posB.add(pos( 2, 0,-2)))

        posA = origin.add(pos(-xOffset, i,-radius))
        posB = origin.add(pos( xOffset, i,-radius))
        blocks.fill(stairs.north, posA, posB)
        blocks.place(stairs.north, posA.add(pos(-1, 0, 1)))
        blocks.place(stairs.north, posA.add(pos(-2, 0, 2)))
        blocks.place(stairs.north, posB.add(pos( 1, 0, 1)))
        blocks.place(stairs.north, posB.add(pos( 2, 0, 2)))

        posA = origin.add(pos( radius, i,-zOffset))
        posB = origin.add(pos( radius, i, zOffset))
        blocks.fill(stairs.west, posA, posB)
        blocks.place(stairs.west, posA.add(pos(-1, 0,-1)))
        blocks.place(stairs.west, posA.add(pos(-2, 0,-2)))
        blocks.place(stairs.west, posB.add(pos(-1, 0, 1)))
        blocks.place(stairs.west, posB.add(pos(-2, 0, 2)))

        posA = origin.add(pos(-radius, i,-zOffset))
        posB = origin.add(pos(-radius, i, zOffset))
        blocks.fill(stairs.east, posA, posB)
        blocks.place(stairs.east, posA.add(pos( 1, 0,-1)))
        blocks.place(stairs.east, posA.add(pos( 2, 0,-2)))
        blocks.place(stairs.east, posB.add(pos( 1, 0, 1)))
        blocks.place(stairs.east, posB.add(pos( 2, 0, 2)))

        --xOffset
        --zOffset
        --radius
    }

    origin = origin.add(pos(0, 2, 0))

    shapes.circle(
        Block.OakWoodSlab,
        origin,
        2,
        Axis.Y,
        ShapeOperation.Replace
    )

    blocks.place(Block.PlanksOak, origin)
}

function castleWindow(origin: Position) {
    blocks.fill(Block.Air, origin, origin.add(pos(0, 1, 0)))
}

function castleTowerLadder(origin: Position, height: number, facing: "north" | "south" | "east" | "west") {
    let ladder = undefined
    switch (facing) {
        case "north":
        ladder = blocks.blockWithData(Block.Ladder, 2)
        break;
        case "south":
        ladder = blocks.blockWithData(Block.Ladder, 3)
        break;
        case "east":
        ladder = blocks.blockWithData(Block.Ladder, 4)
        break;
        case "west":
        ladder = blocks.blockWithData(Block.Ladder, 5)
        break;
    }
    blocks.fill(ladder, origin, origin.add(pos(0, height-1, 0)))
}

function castleWall(midPoint: Position, radius: number, axis: Axis, height: number) {
    if (height <= 0) return;

    --height

    let a = undefined
    let b = undefined

    switch (axis) {
        case Axis.X:
        a = midPoint.add(pos(-radius, 0, -1))
        b = midPoint.add(pos( radius, height, 1))    
        break;

        case Axis.Z:
        a = midPoint.add(pos(-1, 0, -radius))
        b = midPoint.add(pos( 1, height, radius))
        break;
    }

    blocks.fill(Block.StoneBricks, a, b)

    b = b.add(pos(0, 1, 0))
    a = a.add(pos(0, b.getValue(Axis.Y), 0))

    blocks.fill(Block.PlanksOak, a, b)

    let c = undefined
    let d = undefined

    switch (axis) {
        case Axis.X:
        a = pos(a.getValue(Axis.X), a.getValue(Axis.Y), midPoint.getValue(Axis.Z))
        b = pos(b.getValue(Axis.X), a.getValue(Axis.Y)+1, midPoint.getValue(Axis.Z))

        c = a.add(pos(0, 0, 2))
        d = b.add(pos(0, 0, 2))
        blocks.fill(Block.StoneBricks, c, d)

        c = a.add(pos(0, 0,-2))
        d = b.add(pos(0, 0,-2))
        blocks.fill(Block.StoneBricks, c, d)

        midPoint = midPoint.add(pos(0, height+2, 0))

        for (let i = 0; i <= radius; i+=2) {
            blocks.place(Block.StoneBricksSlab, midPoint.add(pos( i, 0, 2)))
            blocks.place(Block.StoneBricksSlab, midPoint.add(pos(-i, 0, 2)))
            blocks.place(Block.StoneBricksSlab, midPoint.add(pos( i, 0,-2)))
            blocks.place(Block.StoneBricksSlab, midPoint.add(pos(-i, 0,-2)))
        }
        
        break;
        case Axis.Z:
        a = pos(midPoint.getValue(Axis.X), a.getValue(Axis.Y), a.getValue(Axis.Z))
        b = pos(midPoint.getValue(Axis.X), a.getValue(Axis.Y)+1, b.getValue(Axis.Z))

        c = a.add(pos( 2, 0, 0))
        d = b.add(pos( 2, 0, 0))
        blocks.fill(Block.StoneBricks, c, d)

        c = a.add(pos(-2, 0, 0))
        d = b.add(pos(-2, 0, 0))
        blocks.fill(Block.StoneBricks, c, d)

        midPoint = midPoint.add(pos(0, height+2, 0))

        for (let i = 0; i <= radius; i+=2) {
            blocks.place(Block.StoneBricksSlab, midPoint.add(pos( 2, 0, i)))
            blocks.place(Block.StoneBricksSlab, midPoint.add(pos( 2, 0,-i)))
            blocks.place(Block.StoneBricksSlab, midPoint.add(pos(-2, 0, i)))
            blocks.place(Block.StoneBricksSlab, midPoint.add(pos(-2, 0,-i)))
        }
        break;
    }

    blocks.fill(Block.Air, a.add(pos(0, 1, 0)), a.add(pos(0, 2, 0)))
    blocks.fill(Block.Air, b.add(pos(0, 0, 0)), b.add(pos(0, 1, 0)))
}

function castleGate(origin: Position) { // south
    const stairs = {
        east: blocks.blockWithData(Block.StoneBrickStairs, 4),
        west: blocks.blockWithData(Block.StoneBrickStairs, 5),
    }

    blocks.fill(Block.Air, origin.add(pos(-1, 0, -1)), origin.add(pos(1, 2, 1)))

    blocks.place(stairs.west, origin.add(pos(-1, 2,-1)))
    blocks.place(stairs.west, origin.add(pos(-1, 2, 1)))
    blocks.place(stairs.east, origin.add(pos( 1, 2,-1)))
    blocks.place(stairs.east, origin.add(pos( 1, 2, 1)))

    blocks.fill(Block.OakFence, origin.add(pos(-1, 2, 0)), origin.add(pos(1, 2, 0)))
}

function castleFosse(a: Position, b: Position) {
    const c = pos(a.getValue(Axis.X), a.getValue(Axis.Y), b.getValue(Axis.Z))
    const d = pos(b.getValue(Axis.X), a.getValue(Axis.Y), a.getValue(Axis.Z))

    blocks.fill(Block.Air, a.add(pos(-2, -1, -2)), c.add(pos(2, -2, 2)))
    blocks.fill(Block.Air, c.add(pos(-2, -1, -2)), b.add(pos(2, -2, 2)))
    blocks.fill(Block.Air, a.add(pos(-2, -1, -2)), d.add(pos(2, -2, 2)))
    blocks.fill(Block.Air, b.add(pos(-2, -1, -2)), d.add(pos(2, -2, 2)))

    blocks.fill(Block.Water, a.add(pos(-2, -3, -2)), c.add(pos(2, -4, 2)))
    blocks.fill(Block.Water, c.add(pos(-2, -3, -2)), b.add(pos(2, -4, 2)))
    blocks.fill(Block.Water, a.add(pos(-2, -3, -2)), d.add(pos(2, -4, 2)))
    blocks.fill(Block.Water, b.add(pos(-2, -3, -2)), d.add(pos(2, -4, 2)))

    blocks.fill(Block.Water, a.add(pos(-1, -4, -1)), c.add(pos(1, -5, 1)))
    blocks.fill(Block.Water, c.add(pos(-1, -4, -1)), b.add(pos(1, -5, 1)))
    blocks.fill(Block.Water, a.add(pos(-1, -4, -1)), d.add(pos(1, -5, 1)))
    blocks.fill(Block.Water, b.add(pos(-1, -4, -1)), d.add(pos(1, -5, 1)))
}

function bridge(origin: Position) {
    const stairs = {
        north: blocks.blockWithData(Block.OakWoodStairs, 2),
        south: blocks.blockWithData(Block.OakWoodStairs, 3),
        north2: blocks.blockWithData(Block.OakWoodStairs, 6),
        south2: blocks.blockWithData(Block.OakWoodStairs, 7)
    }

    const logs = {
        h: blocks.blockWithData(Block.LogOak, 8),
        v: blocks.blockWithData(Block.LogOak, 0)
    }

    blocks.fill(stairs.north, origin.add(pos(-1, 0,-3)), origin.add(pos(1, 0,-3)))
    blocks.fill(stairs.south, origin.add(pos(-1, 0, 3)), origin.add(pos(1, 0, 3)))

    blocks.fill(stairs.south2, origin.add(pos(-1, 0,-2)), origin.add(pos(1, 0,-2)))
    blocks.fill(stairs.north2, origin.add(pos(-1, 0, 2)), origin.add(pos(1, 0, 2)))

    blocks.fill(Block.OakWoodSlab, origin.add(pos(-1, 1, -2)), origin.add(pos(1, 1, 2)))

    blocks.fill(logs.h, origin.add(pos(-2, 1, -2)), origin.add(pos(-2, 1, 2)))
    blocks.fill(logs.h, origin.add(pos( 2, 1, -2)), origin.add(pos( 2, 1, 2)))

    blocks.place(logs.v, origin.add(pos(-2, 0,-3)))
    blocks.place(logs.v, origin.add(pos( 2, 0,-3)))
    blocks.place(logs.v, origin.add(pos(-2, 0, 3)))
    blocks.place(logs.v, origin.add(pos( 2, 0, 3)))

    blocks.fill(Block.OakFence, origin.add(pos(-2, 2, -2)), origin.add(pos(-2, 2, 2)))
    blocks.fill(Block.OakFence, origin.add(pos( 2, 2, -2)), origin.add(pos( 2, 2, 2)))

    blocks.place(Block.OakFence, origin.add(pos(-2, 1,-3)))
    blocks.place(Block.OakFence, origin.add(pos( 2, 1,-3)))
    blocks.place(Block.OakFence, origin.add(pos(-2, 1, 3)))
    blocks.place(Block.OakFence, origin.add(pos( 2, 1, 3)))
}
