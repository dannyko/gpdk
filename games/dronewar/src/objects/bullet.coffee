class @Bullet extends Circle
  constructor: (@config = {}) ->
    super
    @is_bullet = true
    @power = @config.power || 1
    
  destroy_check: (n) -> # bullet handles score value updates 
    return true if n.is_root # don't allow default reaction to occur (let root handle it)
    if n.is_bullet
      n.destroy() unless @is_destroyed # remove extra bullets
      return true
    @destroy() # remove the bullet that hit the drone
    n.deplete(@power) # deplete the drone
    if n.depleted() # detroy the drone if depleted
      Game.increment_score()  # increment score for hitting the drone
      Gameprez?.score(Game.score) # send score update to Gameprez if available
      n.destroy() 
    true