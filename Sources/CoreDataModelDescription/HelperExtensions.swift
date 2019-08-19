import Foundation

extension Sequence {
    
    func associateBy<Key, Value>(_ block: (Element) -> (Key, Value)) -> Dictionary<Key, [Value]> where Key: Hashable {
        var dict: [Key: [Value]] = [:]
        self.forEach { (element) in
            let (key, value) = block(element)
            if var prevValues = dict[key] {
                prevValues.append(value)
                dict[key] = prevValues
            } else {
                dict[key] = [value]
            }
        }
        return dict
    }
}
