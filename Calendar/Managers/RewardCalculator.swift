import Foundation

struct RewardCalculator {
    /// Calculates the base XP using frequency and energy (no length)
    static func baseXP(rewardFrequency: TaskFrequency, rewardEnergy: Int) -> Int {
        let baseXP = 10
        let energyFactor = rewardEnergy
        let frequencyBonus: Int
        switch rewardFrequency {
        case .none: frequencyBonus = 5
        case .daily: frequencyBonus = 0
        case .weekly: frequencyBonus = 10
        case .monthly: frequencyBonus = 20
        }
        let rawXP = baseXP + (energyFactor * 5) + frequencyBonus
        return min(max(rawXP, 5), 100)
    }
    /// Calculates the base coins using frequency and energy (no length)
    static func baseCoins(rewardFrequency: TaskFrequency, rewardEnergy: Int) -> Int {
        let baseCoins = 2
        let energyFactor = rewardEnergy
        let frequencyBonus: Int
        switch rewardFrequency {
        case .none: frequencyBonus = 2
        case .daily: frequencyBonus = 0
        case .weekly: frequencyBonus = 4
        case .monthly: frequencyBonus = 8
        }
        let rawCoins = baseCoins + (energyFactor * 2) + frequencyBonus
        return min(max(rawCoins, 1), 30)
    }
    /// Calculates the final XP using baseXP, length (in seconds), and optional completion (0.0-1.0)
    static func finalXP(baseXP: Int, rewardLength: TimeInterval, completion: Double = 1.0, userMultiplier: Double = 1.0) -> Int {
        let lengthFactor = Int(rewardLength / 60 / 15) // 15 min blocks
        let total = Double(baseXP + (lengthFactor * 5)) * userMultiplier * min(max(completion, 0.0), 1.0)
        return min(max(Int(total), 0), 100)
    }
    /// Calculates the final coins using baseCoins, length (in seconds), and optional completion (0.0-1.0)
    static func finalCoins(baseCoins: Int, rewardLength: TimeInterval, completion: Double = 1.0, userMultiplier: Double = 1.0) -> Int {
        let lengthFactor = Int(rewardLength / 60 / 30) // 30 min blocks
        let total = Double(baseCoins + (lengthFactor * 2)) * userMultiplier * min(max(completion, 0.0), 1.0)
        return min(max(Int(total), 0), 30)
    }
    /// Convenience: Calculate XP for a Rewardable (Task or Event)
    static func xp(for item: Rewardable, completion: Double = 1.0, userMultiplier: Double = 1.0) -> Int {
        let base = baseXP(rewardFrequency: item.rewardFrequency, rewardEnergy: item.rewardEnergy)
        return finalXP(baseXP: base, rewardLength: item.rewardLength, completion: completion, userMultiplier: userMultiplier)
    }
    /// Convenience: Calculate coins for a Rewardable (Task or Event)
    static func coins(for item: Rewardable, completion: Double = 1.0, userMultiplier: Double = 1.0) -> Int {
        let base = baseCoins(rewardFrequency: item.rewardFrequency, rewardEnergy: item.rewardEnergy)
        return finalCoins(baseCoins: base, rewardLength: item.rewardLength, completion: completion, userMultiplier: userMultiplier)
    }
} 
