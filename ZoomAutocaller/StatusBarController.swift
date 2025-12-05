import AppKit
import EventKit
import AVFoundation

class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private var delegate: AppDelegate
    
    var eventStore = EKEventStore()
    var isInit: Bool = false
    var calendars: [EKCalendar] = Array()
    var av: AVAudioPlayer = AVAudioPlayer()

    init(popover: NSPopover, delegate: AppDelegate) {
        self.popover = popover
        self.delegate = delegate
        
        statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.isVisible = true
        
        if let statusBarButton = statusItem.button {
            statusBarButton.image = #imageLiteral(resourceName: "Image")
            statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            statusBarButton.image?.isTemplate = true
            statusBarButton.action = #selector(togglePopover(sender:))
            statusBarButton.target = self
        }
        
        getCalendarEvents()
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) {_ in
            if(self.isInit) {
                print("Polling new cal events")
                self.getCalendarEvents()
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 40.0, repeats: true) {_ in
            if(self.isInit) {
                print("Pooling For New Events")
                self.getNewEvents()
            }
        }
        
    }
    
    
    @objc func togglePopover(sender: AnyObject) {
        if(popover.isShown) {
            hidePopover(sender)
        }
        else {
            showPopover(sender)
        }
    }
    
    func showPopover(_ sender: AnyObject) {
        guard let statusBarButton = statusItem.button else { return }

        if #available(macOS 26.0, *) {
            popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: .maxY)

            // Correct drifting placement on newer macOS by anchoring to the status item window frame.
            if
                let popoverWindow = popover.contentViewController?.view.window,
                let buttonWindow = statusBarButton.window
            {
                let buttonRectInWindow = statusBarButton.convert(statusBarButton.bounds, to: nil)
                let buttonRectOnScreen = NSRect(
                    x: buttonWindow.frame.origin.x + buttonRectInWindow.origin.x,
                    y: buttonWindow.frame.origin.y + buttonRectInWindow.origin.y,
                    width: buttonRectInWindow.width,
                    height: buttonRectInWindow.height
                )

                let targetX = buttonRectOnScreen.midX - (popoverWindow.frame.size.width / 2.0)
                let targetY = buttonRectOnScreen.minY - popoverWindow.frame.size.height

                let offByY = abs(popoverWindow.frame.maxY - buttonRectOnScreen.minY) > 4
                let offByX = abs(popoverWindow.frame.midX - buttonRectOnScreen.midX) > 4
                if offByX || offByY {
                    var frame = popoverWindow.frame
                    frame.origin.x = targetX
                    frame.origin.y = targetY
                    popoverWindow.setFrame(frame, display: true)
                }
            }
        } else {
            popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: .maxY)
        }
    }
    
    
    func hidePopover(_ sender: AnyObject) {
        self.av.stop()
        
        popover.performClose(sender)
    }
    
    func getCalendarEvents() {
        // Every time we get new events, clear the previous ones
        meetings.clearMeetings()
        eventStore.requestAccess(to: .event, completion: {
                granted, error in
                if let error = error {
                   print(error)
                   return
                }
                if (granted) {
                    if(self.calendars.count == 0) {
                        let sources = self.eventStore.sources
                        for source in sources{
                            for calendar in source.calendars(for: .event){
                                self.calendars.append(calendar)
                            }
                        }
                    }
                    
                    let events = findEvents(eventStore: self.eventStore, calendars: self.calendars)

                    for event in events {
                        let eventNotes = event.notes ?? ""

                        let resolvedUrl = findUrls(text: eventNotes)
                        
                        if(resolvedUrl != "") {
                            meetings.addMeeting(resolvedUrl: resolvedUrl, event: event)
                        }
                    }
                    
                    self.isInit = true;
                    self.getNewEvents()
                }
        })
    }
    
    func getNewEvents() {
        if(meetings.meetings.count > 0) {
            let values: [Meeting] = meetings.getCurrentMeetings();
        
            nextMeeting.write(meetings: values)
            
            if(values.count > 0) {
                self.playSound()
                DispatchQueue.main.async {
                    if let statusBarButton = self.statusItem.button {
                        self.delegate.initView()
                        statusBarButton.performClick(self)
                    }
                }
            }
        }
    }
    
    func playSound(ignoreSchedule: Bool = false) {
        if !ignoreSchedule {
            let schedule = NotificationScheduleStore.load()
            if !schedule.shouldRing() {
                return
            }
        }
        
        let autoAsset = UserDefaults.standard.integer(forKey: "ringtone")
        if(!ringtones[autoAsset].isEmpty) {
            let audioAsset = NSDataAsset(name: ringtones[autoAsset])
            if(audioAsset != nil) {
                do {
                    let volume = UserDefaults.standard.float(forKey: "volume")
                    self.av = try AVAudioPlayer(data: audioAsset!.data)
                    self.av.volume = volume / 100
                    self.av.play()
                } catch {
                    print("Failed to play sound")
                }
            }
        }
    }
    
    func openedMeeting() {
        DispatchQueue.main.async {
            if let statusBarButton = self.statusItem.button {
                nextMeeting.clearMeetings()
                self.delegate.initView()
                statusBarButton.performClick(self)
            }
        }
    }
    
    func changedSetting() {
        DispatchQueue.main.async {
            if let statusBarButton = self.statusItem.button {
                statusBarButton.performClick(self)
            }
        }
    }
}
