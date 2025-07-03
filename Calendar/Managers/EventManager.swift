import Foundation

struct EventManager {
    /// Updates the event's progress given the event and how long has been worked on (in seconds).
    /// Returns a new EventModel with updated completionPercentage.
    static func updateEventProgress(event: EventModel, timeWorked: TimeInterval) -> EventModel {
        var updatedEvent = event
        // Clamp progress between 0.0 and 1.0
        let progress = min(max(timeWorked / event.length, 0.0), 1.0)
        updatedEvent.completionPercentage = progress
        return updatedEvent
    }
    /// Calculates the XP and coins earned for a given event and completion level (0.0-1.0)
    static func rewardsForEvent(event: EventModel, completion: Double) -> (xp: Int, coins: Int) {
        let xp = RewardCalculator.finalXP(baseXP: event.baseXP, rewardLength: event.rewardLength, completion: completion)
        let coins = RewardCalculator.finalCoins(baseCoins: event.baseCoins, rewardLength: event.rewardLength, completion: completion)
        return (xp, coins)
    }
} 
