class @Bullet extends Circle
  constructor: (@config = {}) ->
    super
    @is_bullet = true
    @power = @config.power || 1
    
  remove_check: (n) -> # bullet handles score value updates 
    if n.is_root # don't allow default reaction to occur (let root handle it)
      return true 
    if n.is_bullet # i.e. bullet firing rate is too high relative to bullet size and velocity
      # n.remove() unless @is_removed or n.is_removed # remove extra bullets
      return true
    n.deplete(@power) # deplete the drone

    if n.depleted() # remove the drone if depleted
      Game.increment_value()  # increment score for hitting the drone
      Game.instance.text()
      Gameprez?.score(Game.score) # send score update to Gameprez if available
      n.remove()
    @remove() unless n.invincible # remove the bullet that hit the drone 
    true