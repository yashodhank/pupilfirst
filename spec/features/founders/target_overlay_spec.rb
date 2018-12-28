require 'rails_helper'

feature 'Target Overlay' do
  include UserSpecHelper

  let!(:level_1) { create :level, :one }
  let!(:startup) { create :startup, :subscription_active, level: level_1 }
  let!(:founder) { startup.team_lead }
  let!(:target_group_1) { create :target_group, level: level_1, milestone: true }
  let!(:target) { create :target, target_group: target_group_1, days_to_complete: 60, role: Target::ROLE_TEAM }
  let!(:prerequisite_target) { create :target, target_group: target_group_1, days_to_complete: 60, role: Target::ROLE_TEAM }
  let!(:timeline_event) { create :timeline_event, startup: startup, founder: founder, status: TimelineEvent::STATUS_VERIFIED, links: [{ title: 'Some Link', url: 'https://www.example.com', private: false }] }
  let!(:timeline_event_file) { create :timeline_event_file, timeline_event: timeline_event }
  let(:faculty) { create :faculty, slack_username: 'abcd' }
  let!(:feedback) { create :startup_feedback, timeline_event: timeline_event, startup: startup, faculty: faculty }
  let!(:resource_file) { create :resource, targets: [target] }
  let!(:resource_video_file) { create :resource_video_file, targets: [target] }
  let!(:resource_video_embed) { create :resource_video_embed, targets: [target] }
  let!(:resource_link) { create :resource_link, targets: [target] }

  # Quiz target
  let!(:quiz_target) { create :target, target_group: target_group_1, days_to_complete: 60, role: Target::ROLE_TEAM, submittability: Target::SUBMITTABILITY_AUTO_VERIFY }
  let!(:quiz) { create :quiz, target: quiz_target }
  let!(:quiz_question_1) { create :quiz_question, quiz: quiz }
  let!(:q1_answer_1) { create :answer_option, quiz_question: quiz_question_1 }
  let!(:q1_answer_2) { create :answer_option, quiz_question: quiz_question_1 }
  let!(:quiz_question_2) { create :quiz_question, quiz: quiz }
  let!(:q2_answer_1) { create :answer_option, quiz_question: quiz_question_2 }
  let!(:q2_answer_2) { create :answer_option, quiz_question: quiz_question_2 }
  let!(:q2_answer_3) { create :answer_option, quiz_question: quiz_question_2 }
  let!(:q2_answer_4) { create :answer_option, quiz_question: quiz_question_2 }
  let!(:quiz_question_3) { create :quiz_question, quiz: quiz }
  let!(:q3_answer_1) { create :answer_option, quiz_question: quiz_question_3 }
  let!(:q3_answer_2) { create :answer_option, quiz_question: quiz_question_3 }

  before do
    # Create another founder in team.
    create :founder, startup: startup

    quiz_question_1.update!(correct_answer: q1_answer_2)
    quiz_question_2.update!(correct_answer: q2_answer_4)
    quiz_question_3.update!(correct_answer: q3_answer_1)
    founder.update!(dashboard_toured: true)
    sign_in_user founder.user, referer: student_dashboard_path
  end

  context 'when the founder clicks on a pending target', js: true do
    it 'displays the target overlay with all target details' do
      # The target should be listed on the dashboard.
      expect(page).to have_selector('.founder-dashboard-target-header__headline', text: target.title)
      # The dashboard should not have an overlay yet.
      expect(page).to_not have_selector('.target-overlay__overlay')

      # Click on the target.
      find('.founder-dashboard-target-header__headline', text: target.title).click
      # The overlay should now be visible.
      expect(page).to have_selector('.target-overlay__overlay')
      # And the page path must have changed
      expect(page).to have_current_path("/student/dashboard/targets/#{target.id}")

      ## Ensure different components of the overlay display the appropriate details.

      # Close the pnotify first.
      find('.ui-pnotify').click

      # Within the header:
      within('.target-overlay__header') do
        expect(page).to have_selector('.target-overlay-header__headline', text: "Team:#{target.title}")
      end

      # Within the status badge bar:
      within('.target-overlay__status-badge-block') do
        expect(page).to have_selector('.target-overlay-status-badge-bar__badge-icon > i.fa-clock-o')
        expect(page).to have_selector('.target-overlay-status-badge-bar__badge-content > span', text: 'Pending')
        expect(page).to have_selector('.target-overlay-status-badge-bar__hint', text: 'Follow completion instructions and submit!')
      end

      # Test the submit button.
      expect(page).to_not have_selector('.timeline-builder__popup-body')
      find('.target-overlay__header').find('button.btn-timeline-builder').click
      expect(page).to have_selector('.timeline-builder__popup-body')
      find('.timeline-builder__modal-close').click # close the timeline builder.

      # Within the content block:
      within('.target-overlay-content-block') do
        expect(page).to have_selector('.target-overlay-content-block__header', text: 'Description')
        expect(page).to have_selector('.target-overlay-content-block__body--description', text: target.description)

        # Check resource links
        expect(page).to have_content('Library Links')
        expect(page).to have_link(resource_file.title.to_s, href: "/library/#{resource_file.slug}/download")
        expect(page).to have_link(resource_video_file.title.to_s, href: "/library/#{resource_video_file.slug}?watch=true")
        expect(page).to have_link(resource_video_embed.title.to_s, href: "/library/#{resource_video_embed.slug}?watch=true")
        expect(page).to have_link(resource_link.title.to_s, href: "/library/#{resource_link.slug}/download")
      end

      # Within the faculty box:
      within('.target-overlay__faculty-box') do
        expect(page).to have_text("Assigned by:\n#{target.faculty.name}")
        expect(page).to have_selector(".target-overlay__faculty-avatar > img[src='#{target.faculty.image_url}']")
      end
    end

    context 'when the target is auto verified' do
      let!(:target) { create :target, target_group: target_group_1, days_to_complete: 60, role: Target::ROLE_TEAM, submittability: Target::SUBMITTABILITY_AUTO_VERIFY }

      it 'displays submit button with correct label' do
        find('.founder-dashboard-target-header__headline', text: target.title).click

        # The submit button has 'Mark Complete' label
        expect(page).to have_selector('button.btn-timeline-builder > span', text: 'MARK COMPLETE')
      end
    end
  end

  context 'when the founder clicks on a completed target', js: true do
    let!(:timeline_event) { create :timeline_event, startup: startup, target: target, founder: founder, status: TimelineEvent::STATUS_VERIFIED, links: [{ title: 'Some Link', url: 'https://www.example.com', private: false }] }

    it 'displays the latest submission and feedback for it' do
      find('.founder-dashboard-target-header__headline', text: target.title).click

      # Within the timeline event panel:
      within('.target-overlay-timeline-event-panel__container') do
        expect(page).to have_selector('.target-overlay-timeline-event-panel__title', text: 'Latest Timeline Submission:')
        expect(page).to have_selector('.target-overlay-timeline-event-panel__header-title', text: timeline_event.title)
        month_name = timeline_event.event_on.strftime('%b').upcase
        expect(page).to have_selector('.target-overlay-timeline-event-panel__header-date', text: month_name)
        date = "#{timeline_event.event_on.strftime('%e').strip}/#{timeline_event.event_on.strftime('%y')}"
        expect(page).to have_selector('.target-overlay-timeline-event-panel__header-date--large', text: date)
        expect(page).to have_selector('.target-overlay-timeline-event-panel__header-title-date', text: 'Day 1')
        expect(page).to have_selector('.target-overlay-timeline-event-panel__content', text: timeline_event.description)

        # Attachments.
        expect(page).to have_selector("a[href='https://www.example.com'] > .target-overlay__link--attachment-text", text: 'Some Link')
        expect(page).to have_selector("a[href='#{timeline_event_file.file_url}'] > .target-overlay__link--attachment-text", text: timeline_event_file.title)

        # Latest Feedback.
        expect(page).to have_selector('.target-overlay-timeline-event-panel__feedback > p', text: feedback.feedback)
        expect(page).to have_selector(".target-overlay-timeline-event-panel__feedback > div > span > img[src='#{faculty.image_url}']")
        expect(page).to have_selector('.target-overlay-timeline-event-panel__feedback > div > h6 > span', text: faculty.name)

        # Slack connect button.
        expect(page).to have_selector('a[href=\'https://svlabs-public.slack.com/messages/@abcd\']', text: 'Discuss On Slack')
      end
    end
  end

  context 'when the founder clicks a founder target', js: true do
    let!(:target) { create :target, target_group: target_group_1, days_to_complete: 60, role: Target::ROLE_FOUNDER }
    let!(:timeline_event) { create :timeline_event, startup: startup, target: target, founder: founder, status: TimelineEvent::STATUS_VERIFIED, links: [{ title: 'Some Link', url: 'https://www.example.com', private: false }] }

    before do
      visit student_dashboard_path
    end

    it 'displays the status for each founder' do
      find('.founder-dashboard-target-header__headline', text: target.title).click

      within('.target-overlay__content-rightbar') do
        expect(page).to have_selector('.target-overaly__status-title', text: 'Completion Status')
        expect(page).to have_selector('.founder-dashboard__avatar-wrapper', count: 2)
        # TODO: Also check if the right people have the right status. This is now blocked by the bug reported here: https://trello.com/c/P9RNQQ3N
      end
    end
  end

  context 'when the founder clicks a locked target', js: true do
    context 'when the target has prerequisites' do
      before do
        target.prerequisite_targets << prerequisite_target
        visit student_dashboard_path
      end

      it 'informs about the pending prerequisite' do
        find('.founder-dashboard-target-header__headline', text: target.title).click

        # The target must be marked locked.
        within('.target-overlay__status-badge-block') do
          expect(page).to have_selector('.target-overlay-status-badge-bar__badge-icon > i.fa-lock')
          expect(page).to have_selector('.target-overlay-status-badge-bar__badge-content > span', text: 'Locked')
          expect(page).to have_selector('.target-overlay-status-badge-bar__hint', text: 'Complete prerequisites first!')
        end

        within('.target-overlay-content-block') do
          expect(page).to have_selector('.target-overlay-content-block__prerequisites > h6', text: 'Pending Prerequisites:')
          expect(page).to have_selector(".target-overlay-content-block__prerequisites-list-item > a[href='/student/dashboard/targets/#{prerequisite_target.id}']", text: prerequisite_target.title)
        end
      end
    end

    context 'when the target has is not submittable' do
      before do
        target.update!(submittability: Target::SUBMITTABILITY_NOT_SUBMITTABLE)
        visit student_dashboard_path
      end

      it 'informs about the pending prerequisite' do
        find('.founder-dashboard-target-header__headline', text: target.title).click

        # The target must be marked locked.
        within('.target-overlay__status-badge-block') do
          expect(page).to have_selector('.target-overlay-status-badge-bar__badge-icon > i.fa-lock')
          expect(page).to have_selector('.target-overlay-status-badge-bar__badge-content > span', text: 'Locked')
          expect(page).to have_selector('.target-overlay-status-badge-bar__hint', text: 'The target is currently unavailable to complete!')
        end
      end
    end
  end

  context 'when the founder submits a new timeline event', js: true do
    it 'changes the status to submitted right away' do
      find('.founder-dashboard-target-header__headline', text: target.title).click
      # The target must be pending.
      within('.target-overlay__status-badge-block') do
        expect(page).to have_selector('.target-overlay-status-badge-bar__badge-icon > i.fa-clock-o')
        expect(page).to have_selector('.target-overlay-status-badge-bar__badge-content > span', text: 'Pending')
        expect(page).to have_selector('.target-overlay-status-badge-bar__hint', text: 'Follow completion instructions and submit!')
      end

      # Close pnotify first.
      find('.ui-pnotify').click

      find('.target-overlay__header').find('button.btn-timeline-builder').click
      expect(page).to have_selector('.timeline-builder__popup-body')
      find('.timeline-builder__textarea').set('Some description')
      find('.js-timeline-builder__submit-button').click

      # The target status badge must now say submitted.
      within('.target-overlay__status-badge-block') do
        expect(page).to have_selector('.target-overlay-status-badge-bar__badge-icon > i.fa-hourglass-half')
        expect(page).to have_selector('.target-overlay-status-badge-bar__badge-content > span', text: 'Submitted')
        expect(page).to have_selector('.target-overlay-status-badge-bar__hint', text: "Submitted on #{Date.today.strftime('%b %-e')}")
      end
    end
  end

  context 'when the founder submits a quiz target', js: true do
    it 'changes the status to completed right away' do
      find('.founder-dashboard-target-header__headline', text: quiz_target.title).click

      # The target must be pending.
      expect(page).to have_content('Pending')
      expect(page).to have_content('Follow completion instructions and submit!')

      # Close pnotify first.
      find('.ui-pnotify').click

      click_button('Take Quiz')

      # Question one
      find('.quiz-root__answer-option', text: q1_answer_1.value).click
      expect(page).to have_content('Wrong Answer')
      find('.quiz-root__answer-option', text: q1_answer_2.value).click
      expect(page).to have_content('Correct Answer')
      click_button('Next')

      # Question two
      find('.quiz-root__answer-option', text: q2_answer_3.value).click
      expect(page).to have_content('Wrong Answer')
      find('.quiz-root__answer-option', text: q2_answer_4.value).click
      expect(page).to have_content('Correct Answer')
      click_button('Next')

      # Question three
      find('.quiz-root__answer-option', text: q3_answer_2.value).click
      expect(page).to have_content('Wrong Answer')
      find('.quiz-root__answer-option', text: q3_answer_1.value).click
      expect(page).to have_content('Correct Answer')

      # Submit Quiz
      click_button('Submit Quiz')

      expect(page).to have_content("Completed on #{Date.today.strftime('%b %-e')}")
    end
  end

  context 'when the founder clicks the back button from the overlay', js: true do
    it 'takes him/her back to the dashboard' do
      find('.founder-dashboard-target-header__headline', text: target.title).click
      expect(page).to have_selector('.target-overlay__overlay')
      expect(page).to have_current_path("/student/dashboard/targets/#{target.id}")

      find('.target-overlay__overlay-close-icon').click

      # Founder must now be on the dashboard.
      expect(page).to_not have_selector('.target-overlay__overlay')
      expect(page).to have_selector('.founder-dashboard-target-group__container')
      expect(page).to have_current_path('/student/dashboard')
    end
  end
end
