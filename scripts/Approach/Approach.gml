function Approach(start, target, shift) {
    if (start < target) {
        return min(start+shift, target);
    } else {
        return max(start-shift, target);
    }
}